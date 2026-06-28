#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const projectId = 'scanleno-37d42';
const rootDir = path.resolve(__dirname, '..');
const defaultServiceAccountPath = path.join(
  rootDir,
  'secrets',
  'firebase-service-account.json',
);

function parseArgs(argv) {
  const args = { email: null, uid: null };
  for (let index = 2; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--email') {
      args.email = argv[index + 1] || null;
      index += 1;
    } else if (item === '--uid') {
      args.uid = argv[index + 1] || null;
      index += 1;
    }
  }
  return args;
}

function resolveServiceAccountPath() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return path.resolve(process.env.GOOGLE_APPLICATION_CREDENTIALS);
  }
  if (fs.existsSync(defaultServiceAccountPath)) {
    return defaultServiceAccountPath;
  }
  const secretsDir = path.join(rootDir, 'secrets');
  if (!fs.existsSync(secretsDir)) return defaultServiceAccountPath;
  const jsonFiles = fs
    .readdirSync(secretsDir)
    .filter((fileName) => fileName.toLowerCase().endsWith('.json'))
    .sort();
  if (jsonFiles.length === 1) {
    return path.join(secretsDir, jsonFiles[0]);
  }
  return defaultServiceAccountPath;
}

function loadServiceAccount() {
  const serviceAccountPath = resolveServiceAccountPath();
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Service account not found. Put it at ${path.relative(
        rootDir,
        defaultServiceAccountPath,
      )} or set GOOGLE_APPLICATION_CREDENTIALS.`,
    );
  }
  const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
  if (serviceAccount.project_id !== projectId) {
    throw new Error(
      `Service account project_id is ${serviceAccount.project_id}, expected ${projectId}.`,
    );
  }
  return serviceAccount;
}

async function listAuthUsers() {
  const users = [];
  let pageToken;
  do {
    const result = await admin.auth().listUsers(1000, pageToken);
    users.push(...result.users);
    pageToken = result.pageToken;
  } while (pageToken);
  return users;
}

function providerFor(user) {
  if (!user.providerData || user.providerData.length === 0) return 'anonymous';
  return user.providerData.map((provider) => provider.providerId).join(',');
}

function isAnonymous(user) {
  return !user.email && (!user.providerData || user.providerData.length === 0);
}

function authTimestamp(value, fallback) {
  return value || fallback;
}

function publicUserLine(user) {
  return {
    uid: user.uid,
    email: user.email || '',
    displayName: user.displayName || '',
  };
}

function selectOwner(users, args) {
  if (users.length === 0) {
    throw new Error('No Firebase Auth users found.');
  }
  if (args.uid) {
    const byUid = users.find((user) => user.uid === args.uid);
    if (byUid) return byUid;
    const byEmailFromUidArg = users.find(
      (user) => (user.email || '').toLowerCase() === args.uid.toLowerCase(),
    );
    if (byEmailFromUidArg) return byEmailFromUidArg;
    throw new Error(`No Firebase Auth user found for --uid ${args.uid}.`);
  }
  if (args.email) {
    const byEmail = users.find(
      (user) => (user.email || '').toLowerCase() === args.email.toLowerCase(),
    );
    if (byEmail) return byEmail;
    throw new Error(`No Firebase Auth user found for --email ${args.email}.`);
  }
  if (users.length === 1) return users[0];

  console.log('Multiple Firebase Auth users found. Choose an owner with --email or --uid:');
  for (const user of users) {
    console.log(JSON.stringify(publicUserLine(user)));
  }
  process.exitCode = 2;
  return null;
}

async function setClaims(user, role) {
  const currentClaims = user.customClaims || {};
  const roleClaims =
    role === 'owner'
      ? { owner: true, admin: true, role: 'owner' }
      : { owner: false, admin: false, role: 'user' };
  await admin.auth().setCustomUserClaims(user.uid, {
    ...currentClaims,
    ...roleClaims,
  });
}

async function upsertOwnerDocument(db, user) {
  const ref = db.collection('users').doc(user.uid);
  const snapshot = await ref.get();
  const now = new Date().toISOString();
  const existing = snapshot.exists ? snapshot.data() : {};
  const createdAt = existing.createdAt || authTimestamp(user.metadata.creationTime, now);
  const lastLoginAt = authTimestamp(user.metadata.lastSignInTime, null);
  const data = {
    uid: user.uid,
    email: user.email || null,
    displayName: user.displayName || null,
    photoUrl: user.photoURL || null,
    provider: providerFor(user),
    isAnonymous: isAnonymous(user),
    role: 'owner',
    plan: 'yearly',
    premiumActive: true,
    premiumExpiresAt: null,
    platform: 'web',
    monthlyOcrUsed: 0,
    monthlyOcrLimit: 1000,
    scanCredit: 100,
    disabled: false,
    createdAt,
    updatedAt: now,
    lastLoginAt,
  };
  await ref.set(data, { merge: true });
  return { created: !snapshot.exists, ref };
}

async function createDefaultUserDocumentIfMissing(db, user) {
  const ref = db.collection('users').doc(user.uid);
  const snapshot = await ref.get();
  if (snapshot.exists) return { created: false, ref };
  const now = new Date().toISOString();
  const data = {
    uid: user.uid,
    email: user.email || null,
    displayName: user.displayName || null,
    photoUrl: user.photoURL || null,
    provider: providerFor(user),
    isAnonymous: isAnonymous(user),
    role: 'user',
    plan: 'free',
    premiumActive: false,
    premiumExpiresAt: null,
    platform: 'web',
    monthlyOcrUsed: 0,
    monthlyOcrLimit: 0,
    scanCredit: 0,
    disabled: false,
    createdAt: authTimestamp(user.metadata.creationTime, now),
    updatedAt: now,
    lastLoginAt: authTimestamp(user.metadata.lastSignInTime, null),
  };
  await ref.set(data, { merge: false });
  return { created: true, ref };
}

async function main() {
  const args = parseArgs(process.argv);
  const serviceAccount = loadServiceAccount();

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId,
  });

  const db = admin.firestore();
  const users = await listAuthUsers();
  const ownerUser = selectOwner(users, args);
  if (!ownerUser) return;

  let regularMetadataCreated = 0;
  let ownerDocumentCreated = false;

  for (const user of users) {
    if (user.uid === ownerUser.uid) {
      const result = await upsertOwnerDocument(db, user);
      ownerDocumentCreated = result.created;
      await setClaims(user, 'owner');
    } else {
      const result = await createDefaultUserDocumentIfMissing(db, user);
      if (result.created) regularMetadataCreated += 1;
      await setClaims(user, 'user');
    }
  }

  const ownerDoc = await db.collection('users').doc(ownerUser.uid).get();
  const ownerData = ownerDoc.data() || {};
  const collectionCheck = await db.collection('users').limit(1).get();

  console.log('Firebase bootstrap report');
  console.log(JSON.stringify(
    {
      projectId,
      authUsers: users.length,
      usersCollectionReady: !collectionCheck.empty,
      ownerUid: ownerUser.uid,
      ownerDocumentExists: ownerDoc.exists,
      ownerDocumentCreated,
      ownerRole: ownerData.role || null,
      ownerCustomClaimsSet: true,
      regularUsersMetadataCreated: regularMetadataCreated,
      regularUsersClaimsUpdated: Math.max(users.length - 1, 0),
    },
    null,
    2,
  ));
}

main().catch((error) => {
  console.error(`Firebase bootstrap failed: ${error.message}`);
  process.exitCode = 1;
});

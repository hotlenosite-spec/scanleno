const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

loadEnvFile(path.join(__dirname, '.env'));

const port = Number(process.env.SCANLENO_PORT || 8787);
const token = process.env.SCANLENO_API_TOKEN || '';
const firebaseProjectId = process.env.FIREBASE_PROJECT_ID || 'scanleno-37d42';
const dataFile = process.env.SCANLENO_DATA_FILE || path.join(__dirname, 'data', 'scanleno.json');
const isProduction = process.env.NODE_ENV === 'production' || process.env.SCANLENO_ENV === 'production';
const allowedOrigins = String(process.env.SCANLENO_ALLOWED_ORIGINS || '')
  .split(',')
  .map((item) => item.trim())
  .filter(Boolean);
const ocrLimits = {
  maxImageBytes: Number(process.env.SCANLENO_OCR_MAX_IMAGE_BYTES || 8 * 1024 * 1024),
  maxBodyBytes: Number(process.env.SCANLENO_OCR_MAX_BODY_BYTES || 12 * 1024 * 1024),
  perUserPerMinute: Number(process.env.SCANLENO_OCR_USER_RATE_LIMIT_PER_MINUTE || 10),
  perIpPerMinute: Number(process.env.SCANLENO_OCR_IP_RATE_LIMIT_PER_MINUTE || 20)
};
const rewardedCredit = {
  item: process.env.REWARDED_CREDIT_ITEM || 'scan_credit',
  amount: Number(process.env.REWARDED_CREDIT_AMOUNT || 1),
  androidAdUnitId: process.env.ADMOB_REWARDED_ANDROID_AD_UNIT_ID || 'ca-app-pub-5375559288118322/3373021373',
  iosAdUnitId: process.env.ADMOB_REWARDED_IOS_AD_UNIT_ID || 'ca-app-pub-5375559288118322/7312266382',
  ssvEnabled: String(process.env.ADMOB_SSV_ENABLED || '').toLowerCase() === 'true',
  publicKeysUrl: process.env.ADMOB_SSV_PUBLIC_KEYS_URL || 'https://www.gstatic.com/admob/reward/verifier-keys.json',
  devCreditEnabled: String(process.env.SCANLENO_ENABLE_DEV_REWARDED_CREDIT || '').toLowerCase() === 'true',
  customDataSecret: process.env.REWARDED_CUSTOM_DATA_SECRET || process.env.SCANLENO_API_TOKEN || firebaseProjectId
};
const azureDocumentIntelligence = {
  endpoint: process.env.AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT || '',
  region: process.env.AZURE_DOCUMENT_INTELLIGENCE_REGION || '',
  model: process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL || 'prebuilt-layout',
  apiVersion: process.env.AZURE_DOCUMENT_INTELLIGENCE_API_VERSION || '2024-11-30',
  key: process.env.AZURE_DOCUMENT_INTELLIGENCE_KEY || ''
};

const defaults = {
  settings: {
    appName: 'ScanLeno',
    environment: 'development',
    privacy: 'Documents are not uploaded to this backend by default.',
    appMessage: '',
    maintenanceAlert: '',
    specialOffer: ''
  },
  featureFlags: {
    ocrEnabled: false,
    ocrPremiumOnly: true,
    ocrAsPremium: true,
    adsEnabled: true,
    bannerEnabled: true,
    bannerAdsEnabled: true,
    interstitialAfterExportEnabled: true,
    interstitialAdsEnabled: true,
    rewardedAdsEnabled: true,
    homeBannerAdsEnabled: true,
    filesBannerAdsEnabled: true,
    toolsBannerAdsEnabled: true,
    annualOffersEnabled: true,
    advancedPdfToolsEnabled: false,
    watermarkEnabled: false,
    exportWatermarkEnabled: false,
    freeDailyScanLimit: 10,
    freeImageToPdfLimit: 12,
    freeFolderLimit: 3,
    ocrWithScanCreditEnabled: true,
    ocrScanCreditEnabled: true,
    freeDailyOcrLimit: 3,
    premiumMonthlyOcrLimit: 500,
    premiumYearlyOcrLimit: 6000,
    azureOcrEnabled: false,
    azureOcrProvider: 'Azure Document Intelligence',
    azureOcrModel: 'prebuilt-layout'
  },
  stats: {
    users: 0,
    activeUsers: 0,
    documents: 0,
    scans: 0,
    createdPdfs: 0,
    freeUsers: 0,
    premiumUsers: 0,
    topTools: []
  },
  subscriptions: {
    plans: [
      { id: 'free', active: true, productId: null },
      { id: 'monthly', active: false, productId: process.env.SCANLENO_IAP_MONTHLY_ID || 'scanleno_premium_monthly' },
      { id: 'yearly', active: false, productId: process.env.SCANLENO_IAP_YEARLY_ID || process.env.SCANLENO_IAP_ANNUAL_ID || 'scanleno_premium_yearly' }
    ],
    freeTrialEnabled: false
  },
  supportTickets: [],
  appErrors: [],
  rewardSessions: [],
  rewardedEvents: [],
  users: []
};

let firebaseCertCache = { expiresAt: 0, certs: {} };
let admobKeysCache = { expiresAt: 0, keys: {} };
const rateLimits = new Map();

validateProductionEnvironment();

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return;
  const content = fs.readFileSync(filePath, 'utf8');
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const index = trimmed.indexOf('=');
    if (index === -1) continue;
    const key = trimmed.slice(0, index).trim();
    const value = trimmed.slice(index + 1).trim().replace(/^"|"$/g, '');
    if (!process.env[key]) process.env[key] = value;
  }
}

function ensureData() {
  fs.mkdirSync(path.dirname(dataFile), { recursive: true });
  if (!fs.existsSync(dataFile)) {
    fs.writeFileSync(dataFile, JSON.stringify(defaults, null, 2));
  }
  return JSON.parse(fs.readFileSync(dataFile, 'utf8'));
}

function saveData(data) {
  fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
}

function normalizeFeatureFlags(flags) {
  const normalized = { ...defaults.featureFlags, ...flags };
  const alias = (canonical, legacy) => {
    if (normalized[canonical] === undefined && normalized[legacy] !== undefined) normalized[canonical] = normalized[legacy];
    if (normalized[legacy] === undefined && normalized[canonical] !== undefined) normalized[legacy] = normalized[canonical];
  };
  alias('bannerEnabled', 'bannerAdsEnabled');
  alias('interstitialAfterExportEnabled', 'interstitialAdsEnabled');
  alias('ocrPremiumOnly', 'ocrAsPremium');
  alias('ocrWithScanCreditEnabled', 'ocrScanCreditEnabled');
  alias('watermarkEnabled', 'exportWatermarkEnabled');
  return normalized;
}

function validateProductionEnvironment() {
  if (!isProduction) return;
  const missing = [];
  if (!process.env.FIREBASE_PROJECT_ID) missing.push('FIREBASE_PROJECT_ID');
  if (!azureDocumentIntelligence.endpoint) missing.push('AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT');
  if (!azureDocumentIntelligence.key) missing.push('AZURE_DOCUMENT_INTELLIGENCE_KEY');
  if (!process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL) missing.push('AZURE_DOCUMENT_INTELLIGENCE_MODEL');
  if (!allowedOrigins.length) missing.push('SCANLENO_ALLOWED_ORIGINS');
  if (missing.length) {
    throw new Error(`ScanLeno production configuration is incomplete. Missing: ${missing.join(', ')}`);
  }
}

function applyCors(req, res) {
  const origin = req.headers.origin || '';
  if (isProduction) {
    if (origin && allowedOrigins.includes(origin)) {
      res.setHeader('access-control-allow-origin', origin);
      res.setHeader('vary', 'Origin');
    }
  } else {
    res.setHeader('access-control-allow-origin', '*');
  }
  res.setHeader('access-control-allow-methods', 'GET,POST,PUT,OPTIONS');
  res.setHeader('access-control-allow-headers', 'content-type,authorization');
}

function corsAllowed(req) {
  if (!isProduction) return true;
  const origin = req.headers.origin || '';
  return !origin || allowedOrigins.includes(origin);
}

function clientIp(req) {
  return String(req.headers['x-forwarded-for'] || req.socket.remoteAddress || 'unknown')
    .split(',')[0]
    .trim();
}

function rateLimit(req, key, limit, windowMs) {
  const bucketKey = `${key}:${clientIp(req)}`;
  return rateLimitBucket(bucketKey, limit, windowMs);
}

function rateLimitValue(key, value, limit, windowMs) {
  const bucketKey = `${key}:${value || 'anonymous'}`;
  return rateLimitBucket(bucketKey, limit, windowMs);
}

function rateLimitBucket(bucketKey, limit, windowMs) {
  const now = Date.now();
  const bucket = (rateLimits.get(bucketKey) || []).filter((time) => now - time < windowMs);
  if (bucket.length >= limit) return false;
  bucket.push(now);
  rateLimits.set(bucketKey, bucket);
  return true;
}

function send(res, status, body) {
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store'
  });
  res.end(JSON.stringify(body));
}

function safeLog(event, fields = {}) {
  const safe = {
    event,
    requestId: fields.requestId,
    status: fields.status,
    reason: fields.reason,
    sessionId: fields.sessionId,
    transactionId: fields.transactionId
  };
  console.log(JSON.stringify(safe));
}

async function protectedRoute(req, res, options = {}) {
  const header = req.headers.authorization || '';
  if (token && header === `Bearer ${token}`) return true;
  const firebaseUser = await verifyFirebaseRequest(req);
  if (firebaseUser) {
    req.firebaseUser = firebaseUser;
    if (!options.adminOnly) return true;
    if (firebaseUser.owner === true || firebaseUser.admin === true || ['admin', 'owner'].includes(firebaseUser.role)) return true;
    const data = ensureData();
    const account = data.users.find((item) => item.uid === firebaseUser.uid);
    if (account && ['admin', 'owner'].includes(account.role)) return true;
  }
  if (!isProduction && !token && !options.adminOnly) return true;
  send(res, 401, { error: 'AUTH_REQUIRED' });
  return false;
}

async function requireFirebaseUser(req, res, options = {}) {
  const firebaseUser = await verifyFirebaseRequest(req);
  if (!firebaseUser) {
    send(res, 401, { error: 'AUTH_REQUIRED' });
    return null;
  }
  req.firebaseUser = firebaseUser;
  if (!options.adminOnly) return firebaseUser;
  if (firebaseUser.owner === true || firebaseUser.admin === true || ['admin', 'owner'].includes(firebaseUser.role)) {
    return firebaseUser;
  }
  const data = ensureData();
  const account = data.users.find((item) => item.uid === firebaseUser.uid);
  if (account && ['admin', 'owner'].includes(account.role)) return firebaseUser;
  send(res, 403, { error: 'AUTH_REQUIRED' });
  return null;
}

async function verifyFirebaseRequest(req) {
  const header = req.headers.authorization || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) return null;
  try {
    return await verifyFirebaseIdToken(match[1]);
  } catch (_) {
    return null;
  }
}

async function verifyFirebaseIdToken(idToken) {
  const parts = idToken.split('.');
  if (parts.length !== 3) throw new Error('invalid_token');
  const header = JSON.parse(base64UrlDecode(parts[0]).toString('utf8'));
  const payload = JSON.parse(base64UrlDecode(parts[1]).toString('utf8'));
  const cert = (await firebaseCerts())[header.kid];
  if (!cert) throw new Error('unknown_kid');
  const verifier = crypto.createVerify('RSA-SHA256');
  verifier.update(`${parts[0]}.${parts[1]}`);
  verifier.end();
  if (!verifier.verify(cert, parts[2], 'base64url')) throw new Error('bad_signature');
  if (payload.aud !== firebaseProjectId) throw new Error('bad_audience');
  if (payload.iss !== `https://securetoken.google.com/${firebaseProjectId}`) throw new Error('bad_issuer');
  if (Number(payload.exp || 0) * 1000 < Date.now()) throw new Error('expired');
  return {
    uid: payload.user_id || payload.sub,
    email: payload.email || null,
    name: payload.name || null,
    picture: payload.picture || null,
    owner: payload.owner === true,
    admin: payload.admin === true,
    role: payload.role || null,
    firebase: payload.firebase || {}
  };
}

async function firebaseCerts() {
  if (firebaseCertCache.expiresAt > Date.now()) return firebaseCertCache.certs;
  const response = await fetch('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com');
  if (!response.ok) throw new Error('firebase_certs_unavailable');
  const maxAge = Number((response.headers.get('cache-control') || '').match(/max-age=(\d+)/)?.[1] || 3600);
  firebaseCertCache = {
    expiresAt: Date.now() + maxAge * 1000,
    certs: await response.json()
  };
  return firebaseCertCache.certs;
}

function base64UrlDecode(value) {
  return Buffer.from(value.replace(/-/g, '+').replace(/_/g, '/'), 'base64');
}

function base64UrlEncode(buffer) {
  return Buffer.from(buffer)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/g, '');
}

function sanitizedUserMetadata(body, firebaseUser) {
  const provider = String(body.provider || firebaseUser.firebase?.sign_in_provider || 'unknown');
  return {
    uid: firebaseUser.uid,
    email: body.email ? String(body.email) : firebaseUser.email,
    displayName: body.displayName ? String(body.displayName) : firebaseUser.name,
    photoUrl: body.photoUrl ? String(body.photoUrl) : firebaseUser.picture,
    provider,
    isAnonymous: provider === 'anonymous' || body.isAnonymous === true,
    platform: body.platform ? String(body.platform) : null,
    updatedAt: new Date().toISOString(),
    lastLoginAt: new Date().toISOString()
  };
}

function defaultAccountMetadata(incoming, firebaseUser) {
  const isOwner = firebaseUser.owner === true || firebaseUser.role === 'owner';
  const isAdmin = firebaseUser.admin === true || firebaseUser.role === 'admin';
  const role = isOwner ? 'owner' : isAdmin ? 'admin' : 'user';
  const premium = role === 'owner' || role === 'admin';
  return {
    ...incoming,
    plan: premium ? 'yearly' : 'free',
    premiumActive: premium,
    premiumExpiresAt: null,
    monthlyOcrUsed: 0,
    monthlyOcrLimit: premium ? 1000 : 0,
    scanCredit: premium ? 100 : 0,
    disabled: false,
    role,
    createdAt: new Date().toISOString()
  };
}

function accountMetadataFromFirebase(firebaseUser) {
  const provider = firebaseUser.firebase?.sign_in_provider || 'unknown';
  return {
    uid: firebaseUser.uid,
    email: firebaseUser.email,
    displayName: firebaseUser.name,
    photoUrl: firebaseUser.picture,
    provider,
    isAnonymous: provider === 'anonymous',
    platform: null,
    updatedAt: new Date().toISOString(),
    lastLoginAt: new Date().toISOString()
  };
}

function findOrCreateAccount(data, firebaseUser) {
  let account = data.users.find((item) => item.uid === firebaseUser.uid);
  if (!account) {
    account = defaultAccountMetadata(accountMetadataFromFirebase(firebaseUser), firebaseUser);
    data.users.push(account);
    data.stats.users = data.users.length;
  }
  return account;
}

function isAccountPremium(account, firebaseUser) {
  if (account?.disabled === true) return false;
  if (firebaseUser.owner === true || firebaseUser.admin === true) return true;
  if (['owner', 'admin'].includes(firebaseUser.role)) return true;
  return account?.premiumActive === true;
}

function ocrAccessForAccount(data, firebaseUser) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  if (flags.ocrEnabled !== true) {
    return { allowed: false, status: 403, error: 'OCR_DISABLED', creditToConsume: false };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) {
    return { allowed: false, status: 401, error: 'AUTH_REQUIRED', creditToConsume: false, account };
  }
  if (isAccountPremium(account, firebaseUser)) {
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.ocrPremiumOnly === false) {
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.ocrWithScanCreditEnabled !== false && Number(account.scanCredit || 0) > 0) {
    return { allowed: true, creditToConsume: true, account };
  }
  return {
    allowed: false,
    status: 403,
    error: flags.ocrWithScanCreditEnabled !== false ? 'OCR_CREDIT_REQUIRED' : 'PREMIUM_REQUIRED',
    creditToConsume: false,
    account
  };
}

function consumeOcrCreditAfterSuccess(account) {
  if (!account) return 0;
  account.scanCredit = Math.max(0, Number(account.scanCredit || 0) - 1);
  account.updatedAt = new Date().toISOString();
  return account.scanCredit;
}

function grantRewardedScanCredit(data, firebaseUser) {
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) return null;
  account.scanCredit = Number(account.scanCredit || 0) + 1;
  account.updatedAt = new Date().toISOString();
  return account;
}

function supportedRewardedAdUnitIds() {
  return new Set([rewardedCredit.androidAdUnitId, rewardedCredit.iosAdUnitId].filter(Boolean));
}

function createRewardSession(data, firebaseUser, body = {}) {
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 15 * 60 * 1000);
  const rewardSessionId = crypto.randomUUID();
  const platform = ['android', 'ios'].includes(body.platform) ? body.platform : null;
  const adUnitId = String(body.adUnitId || (platform === 'ios' ? rewardedCredit.iosAdUnitId : rewardedCredit.androidAdUnitId));
  if (!supportedRewardedAdUnitIds().has(adUnitId)) {
    return { error: 'INVALID_AD_UNIT_ID' };
  }
  const payload = {
    sid: rewardSessionId,
    uid: firebaseUser.uid,
    exp: expiresAt.toISOString(),
    nonce: crypto.randomBytes(12).toString('hex')
  };
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signature = crypto
    .createHmac('sha256', rewardedCredit.customDataSecret)
    .update(encodedPayload)
    .digest('hex');
  const customData = `${encodedPayload}.${signature}`;
  const session = {
    rewardSessionId,
    userId: firebaseUser.uid,
    customDataHash: crypto.createHash('sha256').update(customData).digest('hex'),
    status: 'pending',
    createdAt: now.toISOString(),
    expiresAt: expiresAt.toISOString(),
    platform,
    adUnitId
  };
  data.rewardSessions = Array.isArray(data.rewardSessions) ? data.rewardSessions : [];
  data.rewardSessions.push(session);
  return { session, customData };
}

function verifyRewardCustomData(customData) {
  const [encodedPayload, signature] = String(customData || '').split('.');
  if (!encodedPayload || !signature) return null;
  const expected = crypto
    .createHmac('sha256', rewardedCredit.customDataSecret)
    .update(encodedPayload)
    .digest('hex');
  if (signature.length !== expected.length) return null;
  if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
  try {
    return JSON.parse(base64UrlDecode(encodedPayload).toString('utf8'));
  } catch (_) {
    return null;
  }
}

function rewardSessionById(data, rewardSessionId) {
  data.rewardSessions = Array.isArray(data.rewardSessions) ? data.rewardSessions : [];
  return data.rewardSessions.find((item) => item.rewardSessionId === rewardSessionId);
}

function rewardEventByTransaction(data, transactionId) {
  data.rewardedEvents = Array.isArray(data.rewardedEvents) ? data.rewardedEvents : [];
  return data.rewardedEvents.find((item) => item.transactionId === transactionId);
}

function grantRewardSession(data, session, transactionId, query = {}) {
  const existing = rewardEventByTransaction(data, transactionId);
  if (existing) return { duplicate: true, event: existing };
  const account = data.users.find((item) => item.uid === session.userId);
  if (!account || account.disabled === true) return { error: 'AUTH_REQUIRED' };
  account.scanCredit = Number(account.scanCredit || 0) + rewardedCredit.amount;
  account.updatedAt = new Date().toISOString();
  session.status = 'granted';
  session.grantedAt = new Date().toISOString();
  session.transactionId = transactionId;
  const event = {
    transactionId,
    rewardSessionId: session.rewardSessionId,
    userId: session.userId,
    adUnitId: String(query.ad_unit || query.ad_unit_id || session.adUnitId || ''),
    rewardAmount: rewardedCredit.amount,
    rewardItem: rewardedCredit.item,
    grantedAt: session.grantedAt,
    status: 'granted'
  };
  data.rewardedEvents.push(event);
  return { duplicate: false, event, scanCredit: account.scanCredit };
}

async function admobPublicKeys() {
  if (admobKeysCache.expiresAt > Date.now()) return admobKeysCache.keys;
  const response = await fetch(rewardedCredit.publicKeysUrl);
  if (!response.ok) throw new Error('admob_keys_unavailable');
  const payload = await response.json();
  const keys = {};
  for (const item of payload.keys || []) {
    const keyId = String(item.keyId || item.key_id || '');
    const pem = item.pem || item.publicKeyPem || item.public_key_pem;
    if (keyId && pem) keys[keyId] = pem;
  }
  admobKeysCache = {
    expiresAt: Date.now() + 60 * 60 * 1000,
    keys
  };
  return keys;
}

async function verifyAdMobSsv(url) {
  if (!rewardedCredit.ssvEnabled) {
    return { ok: false, error: 'REWARDED_SSV_NOT_CONFIGURED' };
  }
  const params = url.searchParams;
  const signature = params.get('signature');
  const keyId = params.get('key_id');
  if (!signature || !keyId) return { ok: false, error: 'REWARDED_SSV_INVALID' };
  const rawQuery = url.search.slice(1);
  const signatureIndex = rawQuery.indexOf('&signature=');
  const message = signatureIndex >= 0 ? rawQuery.slice(0, signatureIndex) : rawQuery.replace(/(^|&)signature=[^&]+/, '');
  const keys = await admobPublicKeys();
  const publicKey = keys[keyId];
  if (!publicKey) return { ok: false, error: 'REWARDED_SSV_UNKNOWN_KEY' };
  const verifier = crypto.createVerify('sha256');
  verifier.update(message);
  verifier.end();
  const normalizedSignature = signature.replace(/-/g, '+').replace(/_/g, '/');
  const ok = verifier.verify(publicKey, normalizedSignature, 'base64');
  return ok ? { ok: true } : { ok: false, error: 'REWARDED_SSV_BAD_SIGNATURE' };
}

function subscriptionStatusForAccount(account, firebaseUser) {
  const premium = isAccountPremium(account, firebaseUser);
  const productId = account?.subscriptionProductId || null;
  const yearly = account?.plan === 'yearly' || account?.plan === 'annual' || productId === 'scanleno_premium_yearly';
  return {
    active: premium,
    isPremium: premium,
    verified: premium,
    plan: premium ? (yearly ? 'yearly' : 'monthly') : 'free',
    productId,
    platform: account?.subscriptionPlatform || null,
    expiresAt: account?.subscriptionExpiresAt || account?.premiumExpiresAt || null,
    source: premium ? 'backend_metadata' : 'backend_metadata',
    status: premium ? (yearly ? 'premiumYearly' : 'premiumMonthly') : 'free',
    reason: premium ? null : 'no_active_subscription'
  };
}

function verificationNotConfiguredStatus(body = {}) {
  return {
    active: false,
    isPremium: false,
    verified: false,
    plan: 'free',
    productId: body.productId || null,
    platform: body.platform || null,
    expiresAt: null,
    source: 'backend',
    status: 'pendingVerification',
    reason: 'verificationNotConfigured'
  };
}

function readBody(req, options = {}) {
  const maxBytes = Number(options.maxBytes || 1024 * 1024 * 16);
  return new Promise((resolve, reject) => {
    let raw = '';
    let received = 0;
    req.on('data', (chunk) => {
      received += chunk.length;
      if (received > maxBytes) {
        const error = new Error('FILE_TOO_LARGE');
        error.code = 'FILE_TOO_LARGE';
        req.destroy(error);
        reject(error);
        return;
      }
      raw += chunk;
    });
    req.on('error', (error) => reject(error));
    req.on('end', () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch (_) {
        const error = new Error('invalid_json');
        error.code = 'invalid_json';
        reject(error);
      }
    });
  });
}

function validateAzureConfig() {
  if (!azureDocumentIntelligence.endpoint) return 'azure_endpoint_missing';
  if (!azureDocumentIntelligence.key) return 'azure_key_missing';
  return null;
}

function normalizeMimeType(value) {
  const mimeType = String(value || '').toLowerCase();
  const supported = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
  return supported.includes(mimeType) ? mimeType : null;
}

function decodeOcrImage(body) {
  if (!body || typeof body.imageBase64 !== 'string' || body.imageBase64.trim().isEmpty) {
    return { error: 'INVALID_FILE' };
  }
  const normalized = body.imageBase64.includes(',')
    ? body.imageBase64.split(',').pop()
    : body.imageBase64;
  if (!/^[a-zA-Z0-9+/=\r\n]+$/.test(normalized)) return { error: 'INVALID_FILE' };
  const imageBuffer = Buffer.from(normalized, 'base64');
  if (!imageBuffer.length) return { error: 'INVALID_FILE' };
  if (imageBuffer.length > ocrLimits.maxImageBytes) return { error: 'FILE_TOO_LARGE' };
  return { imageBuffer };
}

async function analyzeWithAzure({ imageBuffer, mimeType }) {
  const configError = validateAzureConfig();
  if (configError) {
    const error = new Error(configError);
    error.code = configError;
    throw error;
  }
  const endpoint = azureDocumentIntelligence.endpoint.endsWith('/')
    ? azureDocumentIntelligence.endpoint
    : `${azureDocumentIntelligence.endpoint}/`;
  const analyzeUrl = `${endpoint}documentintelligence/documentModels/${encodeURIComponent(azureDocumentIntelligence.model)}:analyze?api-version=${encodeURIComponent(azureDocumentIntelligence.apiVersion)}`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 60000);
  try {
    const response = await fetch(analyzeUrl, {
      method: 'POST',
      headers: {
        'content-type': mimeType,
        'Ocp-Apim-Subscription-Key': azureDocumentIntelligence.key
      },
      body: imageBuffer,
      signal: controller.signal
    });
    if (response.status === 429) {
      const error = new Error('rate_limit');
      error.code = 'rate_limit';
      throw error;
    }
    if (!response.ok && response.status !== 202) {
      const error = new Error('ocr_failed');
      error.code = 'ocr_failed';
      throw error;
    }
    const operationLocation = response.headers.get('operation-location');
    if (!operationLocation) {
      const error = new Error('ocr_failed');
      error.code = 'ocr_failed';
      throw error;
    }
    return await pollAzureResult(operationLocation);
  } catch (error) {
    if (error.name === 'AbortError') {
      error.code = 'timeout';
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

async function pollAzureResult(operationLocation) {
  for (let attempt = 0; attempt < 24; attempt += 1) {
    await new Promise((resolve) => setTimeout(resolve, 1500));
    const response = await fetch(operationLocation, {
      headers: { 'Ocp-Apim-Subscription-Key': azureDocumentIntelligence.key }
    });
    if (response.status === 429) {
      const error = new Error('rate_limit');
      error.code = 'rate_limit';
      throw error;
    }
    if (!response.ok) {
      const error = new Error('ocr_failed');
      error.code = 'ocr_failed';
      throw error;
    }
    const payload = await response.json();
    if (payload.status === 'succeeded') return payload.analyzeResult || {};
    if (payload.status === 'failed') {
      const error = new Error('ocr_failed');
      error.code = 'ocr_failed';
      throw error;
    }
  }
  const error = new Error('timeout');
  error.code = 'timeout';
  throw error;
}

function extractOcrPayload(result) {
  const pages = Array.isArray(result.pages) ? result.pages : [];
  const lines = pages.flatMap((page) =>
    Array.isArray(page.lines) ? page.lines.map((line) => String(line.content || '')).filter(Boolean) : []
  );
  const wordItems = pages.flatMap((page) =>
    Array.isArray(page.words) ? page.words : []
  );
  const words = wordItems.map((word) => String(word.content || '')).filter(Boolean);
  const confidenceValues = wordItems
    .map((word) => Number(word.confidence))
    .filter((value) => Number.isFinite(value));
  const confidence = confidenceValues.length
    ? confidenceValues.reduce((sum, value) => sum + value, 0) / confidenceValues.length
    : null;
  const languages = Array.isArray(result.languages) ? result.languages : [];
  const language = languages[0]?.locale || pages[0]?.spans?.[0]?.locale || null;
  return {
    text: String(result.content || lines.join('\n')),
    lines,
    words,
    language,
    confidence
  };
}

const server = http.createServer(async (req, res) => {
  const data = ensureData();
  const url = new URL(req.url, `http://${req.headers.host}`);
  applyCors(req, res);
  if (!corsAllowed(req)) {
    return send(res, 403, { error: 'CORS_ORIGIN_DENIED' });
  }

  if (req.method === 'OPTIONS') {
    return send(res, 204, {});
  }
  if (req.method === 'GET' && url.pathname === '/health') {
    return send(res, 200, { ok: true });
  }
  if (req.method === 'GET' && url.pathname === '/api/settings') {
    return send(res, 200, data.settings);
  }
  if (req.method === 'PUT' && url.pathname === '/api/settings') {
    if (!(await protectedRoute(req, res))) return;
    const body = await readBody(req);
    data.settings = { ...data.settings, ...body };
    saveData(data);
    return send(res, 200, data.settings);
  }
  if (req.method === 'GET' && url.pathname === '/api/feature-flags') {
    return send(res, 200, {
      ...normalizeFeatureFlags(data.featureFlags),
      azureOcrEnabled: !validateAzureConfig(),
      azureOcrProvider: 'Azure Document Intelligence',
      azureOcrModel: azureDocumentIntelligence.model
    });
  }
  if (req.method === 'PUT' && url.pathname === '/api/feature-flags') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    const body = await readBody(req);
    data.featureFlags = normalizeFeatureFlags({ ...data.featureFlags, ...body });
    saveData(data);
    return send(res, 200, data.featureFlags);
  }
  if (req.method === 'GET' && url.pathname === '/api/stats') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    return send(res, 200, data.stats);
  }
  if (req.method === 'GET' && url.pathname === '/api/users') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    return send(res, 200, data.users);
  }
  if (req.method === 'PUT' && url.pathname.startsWith('/api/users/')) {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    const uid = decodeURIComponent(url.pathname.split('/').pop());
    const body = await readBody(req);
    const account = data.users.find((item) => item.uid === uid);
    if (!account) return send(res, 404, { error: 'not_found' });
    const adminFields = {};
    if (['free', 'monthly', 'yearly'].includes(body.plan)) adminFields.plan = body.plan;
    if (typeof body.premiumActive === 'boolean') adminFields.premiumActive = body.premiumActive;
    if (body.monthlyOcrLimit !== undefined) adminFields.monthlyOcrLimit = Number(body.monthlyOcrLimit);
    if (body.scanCredit !== undefined) adminFields.scanCredit = Number(body.scanCredit);
    if (typeof body.disabled === 'boolean') adminFields.disabled = body.disabled;
    if (['user', 'admin', 'owner'].includes(body.role)) adminFields.role = body.role;
    Object.assign(account, adminFields, { updatedAt: new Date().toISOString() });
    saveData(data);
    return send(res, 200, account);
  }
  if (req.method === 'POST' && url.pathname === '/api/account/sync') {
    if (!(await protectedRoute(req, res))) return;
    if (!req.firebaseUser) return send(res, 401, { error: 'firebase_token_required' });
    const body = await readBody(req);
    const incoming = sanitizedUserMetadata(body, req.firebaseUser);
    const existing = data.users.find((item) => item.uid === incoming.uid);
    if (existing) {
      Object.assign(existing, {
        ...incoming,
        role: existing.role || 'user',
        plan: existing.plan || 'free',
        premiumActive: existing.premiumActive === true,
        premiumExpiresAt: existing.premiumExpiresAt || null,
        monthlyOcrUsed: Number(existing.monthlyOcrUsed || 0),
        monthlyOcrLimit: Number(existing.monthlyOcrLimit || 0),
        scanCredit: Number(existing.scanCredit || 0),
        disabled: existing.disabled === true,
        createdAt: existing.createdAt || new Date().toISOString()
      });
    } else {
      data.users.push(defaultAccountMetadata(incoming, req.firebaseUser));
    }
    data.stats.users = data.users.length;
    data.stats.freeUsers = data.users.filter((item) => item.plan === 'free').length;
    data.stats.premiumUsers = data.users.filter((item) => item.premiumActive === true).length;
    saveData(data);
    return send(res, 200, existing || data.users[data.users.length - 1]);
  }
  if (req.method === 'GET' && url.pathname === '/api/support-tickets') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    return send(res, 200, data.supportTickets);
  }
  if (req.method === 'POST' && url.pathname === '/api/support-tickets') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    const body = await readBody(req);
    const ticket = {
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
      message: String(body.message || ''),
      email: body.email ? String(body.email) : null,
      status: 'open'
    };
    data.supportTickets.push(ticket);
    saveData(data);
    return send(res, 201, ticket);
  }
  if (req.method === 'PUT' && url.pathname.startsWith('/api/support-tickets/')) {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    const id = decodeURIComponent(url.pathname.split('/').pop());
    const body = await readBody(req);
    const ticket = data.supportTickets.find((item) => item.id === id);
    if (!ticket) return send(res, 404, { error: 'not_found' });
    ticket.status = String(body.status || ticket.status || 'open');
    ticket.updatedAt = new Date().toISOString();
    saveData(data);
    return send(res, 200, ticket);
  }
  if (req.method === 'GET' && url.pathname === '/api/app-errors') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    return send(res, 200, data.appErrors);
  }
  if (req.method === 'POST' && url.pathname === '/api/app-errors') {
    if (!(await protectedRoute(req, res, { adminOnly: true }))) return;
    const body = await readBody(req);
    data.appErrors.push({
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
      code: String(body.code || 'unknown'),
      message: String(body.message || '')
    });
    saveData(data);
    return send(res, 201, { ok: true });
  }
  if (req.method === 'GET' && url.pathname === '/api/subscriptions') {
    if (!(await protectedRoute(req, res))) return;
    return send(res, 200, data.subscriptions);
  }
  if (req.method === 'GET' && url.pathname === '/api/subscriptions/status') {
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    const account = findOrCreateAccount(data, firebaseUser);
    saveData(data);
    return send(res, 200, subscriptionStatusForAccount(account, firebaseUser));
  }
  if (req.method === 'POST' && (url.pathname === '/api/subscriptions/verify' || url.pathname === '/api/subscription/verify')) {
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    let body;
    try {
      body = await readBody(req);
    } catch (_) {
      return send(res, 400, { error: 'invalid_json' });
    }
    findOrCreateAccount(data, firebaseUser);
    saveData(data);
    // TODO: Configure server-side Google Play Developer API and App Store Server
    // API verification here. Until those store credentials are available, do not
    // mark users Premium from a client receipt alone.
    return send(res, 200, verificationNotConfiguredStatus(body));
  }
  if (req.method === 'POST' && url.pathname === '/api/subscriptions/restore') {
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    const account = findOrCreateAccount(data, firebaseUser);
    saveData(data);
    const current = subscriptionStatusForAccount(account, firebaseUser);
    if (current.active) return send(res, 200, current);
    return send(res, 200, {
      ...verificationNotConfiguredStatus({ platform: null, productId: null }),
      reason: 'restoreVerificationNotConfigured'
    });
  }
  if (req.method === 'POST' && (url.pathname === '/api/credits/rewarded/start' || url.pathname === '/api/credits/rewarded')) {
    if (!rateLimit(req, 'rewarded_start', 10, 60 * 1000)) return send(res, 429, { error: 'RATE_LIMITED' });
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    findOrCreateAccount(data, firebaseUser);
    let body = {};
    try {
      body = await readBody(req);
    } catch (_) {
      body = {};
    }
    const created = createRewardSession(data, firebaseUser, body);
    if (created.error) return send(res, 400, { error: created.error });
    saveData(data);
    return send(res, 200, {
      rewardSessionId: created.session.rewardSessionId,
      customData: created.customData,
      expiresAt: created.session.expiresAt,
      status: created.session.status,
      ssvRequired: isProduction,
      devCreditEnabled: !isProduction && rewardedCredit.devCreditEnabled
    });
  }
  if (req.method === 'GET' && url.pathname === '/api/credits/rewarded/status') {
    if (!rateLimit(req, 'rewarded_status', 60, 60 * 1000)) return send(res, 429, { error: 'RATE_LIMITED' });
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    const rewardSessionId = url.searchParams.get('rewardSessionId') || '';
    const session = rewardSessionById(data, rewardSessionId);
    if (!session || session.userId !== firebaseUser.uid) return send(res, 404, { error: 'REWARD_SESSION_NOT_FOUND' });
    const account = findOrCreateAccount(data, firebaseUser);
    if (session.status === 'pending' && Date.parse(session.expiresAt) < Date.now()) {
      session.status = 'expired';
      saveData(data);
    }
    if (!isProduction && rewardedCredit.devCreditEnabled && session.status === 'pending' && url.searchParams.get('markEarned') === 'true') {
      grantRewardSession(data, session, `dev-${session.rewardSessionId}`, { ad_unit: session.adUnitId });
      saveData(data);
    }
    return send(res, 200, {
      rewardSessionId: session.rewardSessionId,
      status: session.status,
      scanCredit: Number(account.scanCredit || 0),
      expiresAt: session.expiresAt
    });
  }
  if (req.method === 'GET' && (url.pathname === '/api/ads/admob/ssv' || url.pathname === '/api/credits/rewarded/admob-ssv')) {
    if (!rateLimit(req, 'admob_ssv', 120, 60 * 1000)) return send(res, 429, { error: 'RATE_LIMITED' });
    if (isProduction && !rewardedCredit.ssvEnabled) return send(res, 503, { error: 'REWARDED_SSV_NOT_CONFIGURED' });
    const requestId = crypto.randomUUID();
    try {
      const verified = await verifyAdMobSsv(url);
      if (!verified.ok) {
        safeLog('rewarded_ssv_rejected', { requestId, status: 'rejected', reason: verified.error });
        return send(res, 403, { error: verified.error });
      }
      const customData = url.searchParams.get('custom_data') || url.searchParams.get('customData') || '';
      const payload = verifyRewardCustomData(customData);
      if (!payload) return send(res, 400, { error: 'REWARDED_CUSTOM_DATA_INVALID' });
      const session = rewardSessionById(data, payload.sid);
      if (!session || session.userId !== payload.uid) return send(res, 404, { error: 'REWARD_SESSION_NOT_FOUND' });
      if (Date.parse(session.expiresAt) < Date.now()) {
        session.status = 'expired';
        saveData(data);
        return send(res, 410, { error: 'REWARDED_SESSION_EXPIRED' });
      }
      const transactionId = url.searchParams.get('transaction_id') || url.searchParams.get('transactionId') || `${payload.sid}:${url.searchParams.get('timestamp') || ''}`;
      const rewardAmount = Number(url.searchParams.get('reward_amount') || rewardedCredit.amount);
      const rewardItem = url.searchParams.get('reward_item') || rewardedCredit.item;
      const adUnitId = url.searchParams.get('ad_unit') || url.searchParams.get('ad_unit_id') || session.adUnitId;
      if (rewardAmount !== rewardedCredit.amount || rewardItem !== rewardedCredit.item || !supportedRewardedAdUnitIds().has(adUnitId)) {
        session.status = 'rejected';
        saveData(data);
        return send(res, 400, { error: 'REWARDED_PAYLOAD_MISMATCH' });
      }
      const granted = grantRewardSession(data, session, transactionId, Object.fromEntries(url.searchParams.entries()));
      if (granted.error) return send(res, 401, { error: granted.error });
      saveData(data);
      safeLog('rewarded_credit_granted', {
        requestId,
        status: granted.duplicate ? 'duplicate' : 'granted',
        sessionId: session.rewardSessionId,
        transactionId
      });
      return send(res, 200, { ok: true, status: granted.duplicate ? 'duplicate' : 'granted' });
    } catch (_) {
      safeLog('rewarded_ssv_error', { requestId, status: 'error', reason: 'verification_failed' });
      return send(res, 400, { error: 'REWARDED_VERIFICATION_FAILED' });
    }
  }
  if (req.method === 'POST' && url.pathname === '/api/ocr/analyze') {
    const requestId = crypto.randomUUID();
    if (!rateLimit(req, 'ocr_ip', ocrLimits.perIpPerMinute, 60 * 1000)) {
      safeLog('ocr_rejected', { requestId, status: 'rate_limited', reason: 'ip' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) {
      safeLog('ocr_rejected', { requestId, status: 'rejected', reason: 'auth' });
      return;
    }
    if (!rateLimitValue('ocr_user', firebaseUser.uid, ocrLimits.perUserPerMinute, 60 * 1000)) {
      safeLog('ocr_rejected', { requestId, status: 'rate_limited', reason: 'user' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    let body;
    try {
      body = await readBody(req, { maxBytes: ocrLimits.maxBodyBytes });
    } catch (error) {
      const code = error.code === 'FILE_TOO_LARGE' ? 'FILE_TOO_LARGE' : 'INVALID_FILE';
      safeLog('ocr_rejected', { requestId, status: 'rejected', reason: code });
      return send(res, code === 'FILE_TOO_LARGE' ? 413 : 400, { error: code });
    }
    const access = ocrAccessForAccount(data, firebaseUser);
    if (!access.allowed) {
      safeLog('ocr_rejected', { requestId, status: 'rejected', reason: access.error });
      return send(res, access.status || 403, { error: access.error });
    }
    const mimeType = normalizeMimeType(body.mimeType);
    if (!mimeType) return send(res, 415, { error: 'INVALID_FILE' });
    const decoded = decodeOcrImage(body);
    if (decoded.error) return send(res, decoded.error === 'FILE_TOO_LARGE' ? 413 : 400, { error: decoded.error });
    const configError = validateAzureConfig();
    if (configError) return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
    try {
      const result = await analyzeWithAzure({ imageBuffer: decoded.imageBuffer, mimeType });
      const extracted = extractOcrPayload(result);
      let remainingScanCredit = access.account ? Number(access.account.scanCredit || 0) : 0;
      if (access.creditToConsume) {
        remainingScanCredit = consumeOcrCreditAfterSuccess(access.account);
      }
      if (access.account) {
        access.account.monthlyOcrUsed = Number(access.account.monthlyOcrUsed || 0) + 1;
        access.account.updatedAt = new Date().toISOString();
      }
      saveData(data);
      return send(res, 200, {
        documentId: String(body.documentId || ''),
        pageIndex: Number(body.pageIndex || body.pageId || 0),
        text: extracted.text,
        lines: extracted.lines,
        words: extracted.words,
        language: extracted.language,
        confidence: extracted.confidence,
        provider: 'azure_document_intelligence',
        model: azureDocumentIntelligence.model,
        createdAt: new Date().toISOString(),
        creditConsumed: access.creditToConsume,
        remainingScanCredit
      });
    } catch (error) {
      const code = error.code || 'ocr_failed';
      safeLog('ocr_failed', { requestId, status: 'failed', reason: code });
      if (code === 'rate_limit') return send(res, 429, { error: 'RATE_LIMITED' });
      if (code === 'timeout') return send(res, 504, { error: 'AZURE_OCR_FAILED' });
      if (code === 'azure_key_missing' || code === 'azure_endpoint_missing') {
        return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
      }
      return send(res, 502, { error: 'AZURE_OCR_FAILED' });
    }
  }

  return send(res, 404, { error: 'not_found' });
});

server.listen(port, () => {
  console.log(`ScanLeno backend listening on ${port}`);
});

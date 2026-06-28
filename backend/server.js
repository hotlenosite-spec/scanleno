const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

loadEnvFile(path.join(__dirname, '.env'));

const port = Number(process.env.SCANLENO_PORT || 8787);
const token = process.env.SCANLENO_API_TOKEN || '';
const firebaseProjectId = process.env.FIREBASE_PROJECT_ID || 'scanleno-37d42';
const dataFile = process.env.SCANLENO_DATA_FILE || path.join(__dirname, 'data', 'scanleno.json');
const azureDocumentIntelligence = {
  endpoint: process.env.AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT || '',
  region: process.env.AZURE_DOCUMENT_INTELLIGENCE_REGION || '',
  model: process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL || 'prebuilt-read',
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
    azureOcrModel: 'prebuilt-read'
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
      { id: 'annual', active: false, productId: process.env.SCANLENO_IAP_ANNUAL_ID || 'scanleno_premium_annual' }
    ],
    freeTrialEnabled: false
  },
  supportTickets: [],
  appErrors: [],
  users: []
};

let firebaseCertCache = { expiresAt: 0, certs: {} };

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

function send(res, status, body) {
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET,POST,PUT,OPTIONS',
    'access-control-allow-headers': 'content-type,authorization'
  });
  res.end(JSON.stringify(body));
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
  if (!token && !options.adminOnly) return true;
  send(res, 401, { error: 'unauthorized' });
  return false;
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

function readBody(req) {
  return new Promise((resolve) => {
    let raw = '';
    req.on('data', (chunk) => {
      raw += chunk;
      if (raw.length > 1024 * 1024 * 16) req.destroy();
    });
    req.on('end', () => resolve(raw ? JSON.parse(raw) : {}));
  });
}

function ocrAllowed(data, body) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  const userPlan = String(body.userPlan || 'free').toLowerCase();
  const scanCreditAvailable = body.scanCreditAvailable === true;
  if (userPlan === 'premium') return { allowed: true, creditConsumed: false };
  if (flags.ocrPremiumOnly === false) return { allowed: true, creditConsumed: false };
  if (flags.ocrWithScanCreditEnabled !== false && scanCreditAvailable) {
    return { allowed: true, creditConsumed: true };
  }
  return { allowed: false, creditConsumed: false };
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
  if (req.method === 'POST' && url.pathname === '/api/subscription/verify') {
    return send(res, 200, { active: false, source: 'not-configured' });
  }
  if (req.method === 'GET' && url.pathname === '/api/subscriptions') {
    if (!(await protectedRoute(req, res))) return;
    return send(res, 200, data.subscriptions);
  }
  if (req.method === 'POST' && url.pathname === '/api/ocr/analyze') {
    if (!(await protectedRoute(req, res))) return;
    let body;
    try {
      body = await readBody(req);
    } catch (_) {
      return send(res, 400, { error: 'invalid_json' });
    }
    const access = ocrAllowed(data, body);
    if (!access.allowed) {
      return send(res, 403, {
        error: 'ocr_requires_premium_or_scan_credit',
        message: 'OCR requires Premium or one scan_credit.'
      });
    }
    const mimeType = normalizeMimeType(body.mimeType);
    if (!mimeType) return send(res, 415, { error: 'unsupported_file' });
    if (!body.imageBase64) return send(res, 400, { error: 'unsupported_file' });
    const configError = validateAzureConfig();
    if (configError) return send(res, 503, { error: configError });
    try {
      const imageBuffer = Buffer.from(String(body.imageBase64), 'base64');
      const result = await analyzeWithAzure({ imageBuffer, mimeType });
      const extracted = extractOcrPayload(result);
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
        creditConsumed: access.creditConsumed
      });
    } catch (error) {
      const code = error.code || 'ocr_failed';
      if (code === 'rate_limit') return send(res, 429, { error: 'rate_limit' });
      if (code === 'timeout') return send(res, 504, { error: 'timeout' });
      if (code === 'azure_key_missing' || code === 'azure_endpoint_missing') {
        return send(res, 503, { error: code });
      }
      return send(res, 502, { error: 'ocr_failed' });
    }
  }

  return send(res, 404, { error: 'not_found' });
});

server.listen(port, () => {
  console.log(`ScanLeno backend listening on ${port}`);
});

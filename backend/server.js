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
const pdfToExcelLimits = {
  maxPdfBytes: Number(process.env.SCANLENO_PDF_TO_EXCEL_MAX_PDF_BYTES || 15 * 1024 * 1024),
  maxBodyBytes: Number(process.env.SCANLENO_PDF_TO_EXCEL_MAX_BODY_BYTES || 22 * 1024 * 1024),
  perUserPerMinute: Number(process.env.SCANLENO_PDF_TO_EXCEL_USER_RATE_LIMIT_PER_MINUTE || 6),
  perIpPerMinute: Number(process.env.SCANLENO_PDF_TO_EXCEL_IP_RATE_LIMIT_PER_MINUTE || 12)
};
const pdfToWordLimits = {
  maxPdfBytes: Number(process.env.SCANLENO_PDF_TO_WORD_MAX_PDF_BYTES || 15 * 1024 * 1024),
  maxBodyBytes: Number(process.env.SCANLENO_PDF_TO_WORD_MAX_BODY_BYTES || 22 * 1024 * 1024),
  perUserPerMinute: Number(process.env.SCANLENO_PDF_TO_WORD_USER_RATE_LIMIT_PER_MINUTE || 6),
  perIpPerMinute: Number(process.env.SCANLENO_PDF_TO_WORD_IP_RATE_LIMIT_PER_MINUTE || 12)
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
  readModel: process.env.AZURE_DOCUMENT_INTELLIGENCE_READ_MODEL || process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL || 'prebuilt-read',
  layoutModel: process.env.AZURE_DOCUMENT_INTELLIGENCE_LAYOUT_MODEL || 'prebuilt-layout',
  model: process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL || process.env.AZURE_DOCUMENT_INTELLIGENCE_READ_MODEL || 'prebuilt-read',
  apiVersion: process.env.AZURE_DOCUMENT_INTELLIGENCE_API_VERSION || '2024-11-30',
  key: process.env.AZURE_DOCUMENT_INTELLIGENCE_KEY || ''
};
const azureTranslator = {
  enabled: String(process.env.AI_TRANSLATE_ENABLED || process.env.AZURE_TRANSLATOR_ENABLED || '').toLowerCase() === 'true',
  provider: process.env.AI_TRANSLATE_PROVIDER || 'azure_translator',
  endpoint: process.env.AZURE_TRANSLATOR_ENDPOINT || '',
  region: process.env.AZURE_TRANSLATOR_REGION || 'global',
  key: process.env.AZURE_TRANSLATOR_KEY || '',
  model: process.env.AI_TRANSLATE_MODEL || '',
  maxTextChars: Number(process.env.SCANLENO_TRANSLATE_MAX_TEXT_CHARS || 10000),
  perUserPerMinute: Number(process.env.SCANLENO_TRANSLATE_USER_RATE_LIMIT_PER_MINUTE || 20),
  perIpPerMinute: Number(process.env.SCANLENO_TRANSLATE_IP_RATE_LIMIT_PER_MINUTE || 40)
};
const azureOpenAi = {
  enabled: String(process.env.AI_FEATURES_ENABLED || process.env.AZURE_AI_SUMMARY_ENABLED || process.env.AZURE_OPENAI_SUMMARY_ENABLED || '').toLowerCase() === 'true',
  provider: process.env.AI_PROVIDER || 'azure_openai',
  projectEndpoint: process.env.AZURE_AI_PROJECT_ENDPOINT || '',
  endpoint: process.env.AZURE_OPENAI_ENDPOINT || '',
  key: process.env.AI_API_KEY || process.env.AZURE_OPENAI_KEY || '',
  deployment: process.env.AZURE_OPENAI_DEPLOYMENT || process.env.AI_SUMMARY_MODEL || 'scanleno-gpt-4o-mini',
  model: process.env.AI_SUMMARY_MODEL || process.env.AZURE_OPENAI_MODEL || 'gpt-4o-mini',
  apiVersion: process.env.AZURE_OPENAI_API_VERSION || '2024-12-01-preview',
  maxTextChars: Number(process.env.SCANLENO_AI_SUMMARY_MAX_TEXT_CHARS || 12000),
  perUserPerMinute: Number(process.env.SCANLENO_AI_SUMMARY_USER_RATE_LIMIT_PER_MINUTE || 10),
  perIpPerMinute: Number(process.env.SCANLENO_AI_SUMMARY_IP_RATE_LIMIT_PER_MINUTE || 20)
};
const stripeWeb = {
  enabled: String(process.env.STRIPE_WEB_ENABLED || '').toLowerCase() === 'true',
  mode: String(process.env.STRIPE_MODE || 'test').toLowerCase() === 'live' ? 'live' : 'test',
  secretKey: process.env.STRIPE_SECRET_KEY || '',
  publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || '',
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  monthlyPriceId: process.env.STRIPE_SCANLENO_MONTHLY_PRICE_ID || '',
  yearlyPriceId: process.env.STRIPE_SCANLENO_YEARLY_PRICE_ID || '',
  successUrl: process.env.STRIPE_SUCCESS_URL || '',
  cancelUrl: process.env.STRIPE_CANCEL_URL || ''
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
    freeExportWatermarkRequired: true,
    defaultWatermarkText: 'ScanLeno',
    defaultWatermarkOpacity: 0.14,
    defaultWatermarkPosition: 'center',
    premiumCustomWatermarkEnabled: true,
    signatureEnabled: true,
    signaturePremiumOnly: true,
    watermarkPremiumOnly: true,
    translateEnabled: azureTranslator.enabled,
    translatePremiumOnly: true,
    translateWithScanCreditEnabled: false,
    freeDailyTranslateLimit: 3,
    premiumMonthlyTranslateLimit: 500,
    translatorProvider: 'Azure Translator',
    translatorRegion: 'global',
    aiSummaryEnabled: azureOpenAi.enabled,
    aiSummaryPremiumOnly: true,
    aiSummaryWithScanCreditEnabled: false,
    freeDailySummaryLimit: 3,
    premiumMonthlySummaryLimit: 500,
    aiSummaryProvider: 'Azure OpenAI',
    aiSummaryModel: 'gpt-4o-mini',
    aiSummaryDeployment: 'scanleno-gpt-4o-mini',
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
    azureOcrModel: 'prebuilt-read',
    azureOcrReadModel: 'prebuilt-read',
    azureOcrLayoutModel: 'prebuilt-layout',
    defaultOcrLanguage: 'auto',
    allowAutoLanguageDetection: true,
    advancedOcrLanguagesEnabled: false,
    pdfToExcelEnabled: String(process.env.PDF_TO_EXCEL_ENABLED || '').toLowerCase() === 'true',
    pdfToExcelPremiumOnly: true,
    pdfToExcelWithScanCreditEnabled: false,
    freeDailyPdfToExcelLimit: 3,
    premiumMonthlyPdfToExcelLimit: 200,
    pdfToExcelProvider: 'Azure Document Intelligence',
    pdfToExcelModel: 'prebuilt-layout',
    pdfToWordEnabled: String(process.env.PDF_TO_WORD_ENABLED || '').toLowerCase() === 'true',
    pdfToWordPremiumOnly: true,
    pdfToWordWithScanCreditEnabled: false,
    freeDailyPdfToWordLimit: 3,
    premiumMonthlyPdfToWordLimit: 200,
    pdfToWordProvider: 'Azure Document Intelligence',
    pdfToWordModel: 'prebuilt-layout'
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
let stripeClientCache = null;
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
  normalized.translatorProvider = normalized.translatorProvider || 'Azure Translator';
  normalized.translatorRegion = azureTranslator.region || normalized.translatorRegion || 'global';
  normalized.aiSummaryProvider = normalized.aiSummaryProvider || 'Azure OpenAI';
  normalized.aiSummaryModel = azureOpenAi.model || normalized.aiSummaryModel || 'gpt-4o-mini';
  normalized.aiSummaryDeployment = azureOpenAi.deployment || normalized.aiSummaryDeployment || 'scanleno-gpt-4o-mini';
  normalized.pdfToExcelProvider = normalized.pdfToExcelProvider || 'Azure Document Intelligence';
  normalized.pdfToExcelModel = azureDocumentIntelligence.layoutModel || normalized.pdfToExcelModel || 'prebuilt-layout';
  normalized.pdfToWordProvider = normalized.pdfToWordProvider || 'Azure Document Intelligence';
  normalized.pdfToWordModel = azureDocumentIntelligence.layoutModel || normalized.pdfToWordModel || 'prebuilt-layout';
  normalized.signaturePremiumOnly = normalized.signaturePremiumOnly !== false;
  normalized.watermarkPremiumOnly = normalized.watermarkPremiumOnly !== false;
  return normalized;
}

function validateProductionEnvironment() {
  if (!isProduction) return;
  const missing = [];
  if (!process.env.FIREBASE_PROJECT_ID) missing.push('FIREBASE_PROJECT_ID');
  if (!azureDocumentIntelligence.endpoint) missing.push('AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT');
  if (!azureDocumentIntelligence.key) missing.push('AZURE_DOCUMENT_INTELLIGENCE_KEY');
  if (!process.env.AZURE_DOCUMENT_INTELLIGENCE_READ_MODEL && !process.env.AZURE_DOCUMENT_INTELLIGENCE_MODEL) {
    missing.push('AZURE_DOCUMENT_INTELLIGENCE_READ_MODEL');
  }
  if (!process.env.AZURE_DOCUMENT_INTELLIGENCE_LAYOUT_MODEL) missing.push('AZURE_DOCUMENT_INTELLIGENCE_LAYOUT_MODEL');
  if (!allowedOrigins.length) missing.push('SCANLENO_ALLOWED_ORIGINS');
  if (stripeWeb.enabled) missing.push(...stripeMissingConfig({ includePublishable: true }));
  if (azureTranslator.enabled) {
    if (!azureTranslator.endpoint) missing.push('AZURE_TRANSLATOR_ENDPOINT');
    if (!azureTranslator.key) missing.push('AZURE_TRANSLATOR_KEY');
  }
  if (azureOpenAi.enabled) {
    if (!azureOpenAi.endpoint) missing.push('AZURE_OPENAI_ENDPOINT');
    if (!azureOpenAi.key) missing.push('AZURE_OPENAI_KEY');
    if (!azureOpenAi.deployment) missing.push('AZURE_OPENAI_DEPLOYMENT');
    if (!azureOpenAi.model) missing.push('AZURE_OPENAI_MODEL');
  }
  if (missing.length) {
    throw new Error(`ScanLeno production configuration is incomplete. Missing: ${missing.join(', ')}`);
  }
}

function stripeMissingConfig(options = {}) {
  if (!stripeWeb.enabled) return [];
  const includePublishable = options.includePublishable === true;
  const missing = [];
  if (!stripeWeb.secretKey) missing.push('STRIPE_SECRET_KEY');
  if (!stripeWeb.webhookSecret) missing.push('STRIPE_WEBHOOK_SECRET');
  if (!stripeWeb.monthlyPriceId) missing.push('STRIPE_SCANLENO_MONTHLY_PRICE_ID');
  if (!stripeWeb.yearlyPriceId) missing.push('STRIPE_SCANLENO_YEARLY_PRICE_ID');
  if (!stripeWeb.successUrl) missing.push('STRIPE_SUCCESS_URL');
  if (!stripeWeb.cancelUrl) missing.push('STRIPE_CANCEL_URL');
  if (includePublishable && !stripeWeb.publishableKey) missing.push('STRIPE_PUBLISHABLE_KEY');
  return missing;
}

function stripeCheckoutMissingConfig() {
  return stripeMissingConfig().filter((item) => item !== 'STRIPE_WEBHOOK_SECRET');
}

function stripeClient() {
  if (!stripeWeb.enabled) return null;
  if (!stripeWeb.secretKey) {
    const error = new Error('STRIPE_CONFIG_ERROR');
    error.code = 'STRIPE_CONFIG_ERROR';
    throw error;
  }
  if (!stripeClientCache) {
    const Stripe = require('stripe');
    stripeClientCache = Stripe(stripeWeb.secretKey, {
      apiVersion: '2026-06-24.dahlia'
    });
  }
  return stripeClientCache;
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
    transactionId: fields.transactionId,
    userId: fields.userId,
    stripeEvent: fields.stripeEvent
  };
  console.log(JSON.stringify(safe));
}

function stripePlanPriceId(plan) {
  return plan === 'monthly'
    ? stripeWeb.monthlyPriceId
    : plan === 'yearly'
      ? stripeWeb.yearlyPriceId
      : null;
}

function planFromStripePriceId(priceId) {
  if (priceId === stripeWeb.monthlyPriceId) return 'monthly';
  if (priceId === stripeWeb.yearlyPriceId) return 'yearly';
  return null;
}

function stripeSubscriptionIsActive(status) {
  return ['active', 'trialing'].includes(String(status || ''));
}

function stripeTimestampToIso(value) {
  const timestamp = Number(value || 0);
  return timestamp > 0 ? new Date(timestamp * 1000).toISOString() : null;
}

function ensureStripeAccount(data, uid) {
  let account = data.users.find((item) => item.uid === uid);
  if (!account) {
    account = {
      uid,
      email: null,
      displayName: null,
      photoUrl: null,
      provider: 'stripe_web',
      isAnonymous: false,
      role: 'user',
      plan: 'free',
      premiumActive: false,
      premiumExpiresAt: null,
      platform: 'web',
      monthlyOcrUsed: 0,
      monthlyOcrLimit: 0,
      scanCredit: 0,
      disabled: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      lastLoginAt: null
    };
    data.users.push(account);
    data.stats.users = data.users.length;
  }
  return account;
}

function updateSubscriptionStats(data) {
  data.stats.users = Array.isArray(data.users) ? data.users.length : 0;
  data.stats.freeUsers = data.users.filter((item) => item.plan === 'free').length;
  data.stats.premiumUsers = data.users.filter((item) => item.premiumActive === true).length;
}

function applyStripeSubscriptionToAccount(data, uid, details = {}) {
  if (!uid) return null;
  const account = ensureStripeAccount(data, uid);
  const active = stripeSubscriptionIsActive(details.status);
  const plan = active ? details.plan || 'monthly' : 'free';
  Object.assign(account, {
    plan,
    premiumActive: active,
    premiumExpiresAt: active ? details.currentPeriodEnd || null : null,
    subscriptionProductId: details.productId || null,
    subscriptionPlatform: 'stripe_web',
    subscriptionProvider: 'stripe',
    subscriptionCustomerId: details.customerId || account.subscriptionCustomerId || null,
    subscriptionId: details.subscriptionId || account.subscriptionId || null,
    subscriptionStatus: details.status || null,
    subscriptionExpiresAt: active ? details.currentPeriodEnd || null : null,
    monthlyOcrLimit: active
      ? (plan === 'yearly' ? defaults.featureFlags.premiumYearlyOcrLimit : defaults.featureFlags.premiumMonthlyOcrLimit)
      : Number(account.monthlyOcrLimit || 0),
    updatedAt: new Date().toISOString()
  });
  updateSubscriptionStats(data);
  return account;
}

function stripeSubscriptionDetails(subscription) {
  const item = Array.isArray(subscription?.items?.data) ? subscription.items.data[0] : null;
  const priceId = item?.price?.id || null;
  return {
    subscriptionId: typeof subscription?.id === 'string' ? subscription.id : null,
    customerId: typeof subscription?.customer === 'string' ? subscription.customer : subscription?.customer?.id || null,
    status: subscription?.status || null,
    productId: priceId,
    plan: planFromStripePriceId(priceId) || subscription?.metadata?.plan || null,
    currentPeriodEnd: stripeTimestampToIso(subscription?.current_period_end)
  };
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
    monthlyTranslateUsed: 0,
    monthlyTranslateLimit: premium ? defaults.featureFlags.premiumMonthlyTranslateLimit : 0,
    dailyTranslateUsed: 0,
    dailyTranslateDay: null,
    lastTranslateAt: null,
    monthlySummaryUsed: 0,
    monthlySummaryLimit: premium ? defaults.featureFlags.premiumMonthlySummaryLimit : 0,
    dailySummaryUsed: 0,
    dailySummaryDay: null,
    lastSummaryAt: null,
    monthlyPdfToExcelUsed: 0,
    monthlyPdfToExcelLimit: premium ? defaults.featureFlags.premiumMonthlyPdfToExcelLimit : 0,
    dailyPdfToExcelUsed: 0,
    dailyPdfToExcelDay: null,
    lastPdfToExcelAt: null,
    monthlyPdfToWordUsed: 0,
    monthlyPdfToWordLimit: premium ? defaults.featureFlags.premiumMonthlyPdfToWordLimit : 0,
    dailyPdfToWordUsed: 0,
    dailyPdfToWordDay: null,
    lastPdfToWordAt: null,
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
  const yearly =
    account?.plan === 'yearly' ||
    account?.plan === 'annual' ||
    productId === 'scanleno_premium_yearly' ||
    productId === stripeWeb.yearlyPriceId;
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

function readRawBody(req, options = {}) {
  const maxBytes = Number(options.maxBytes || 1024 * 1024);
  return new Promise((resolve, reject) => {
    const chunks = [];
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
      chunks.push(chunk);
    });
    req.on('error', (error) => reject(error));
    req.on('end', () => resolve(Buffer.concat(chunks)));
  });
}

async function handleStripeEvent(stripe, data, event) {
  const object = event?.data?.object || {};
  switch (event.type) {
    case 'checkout.session.completed': {
      const uid = object.client_reference_id || object.metadata?.userId || null;
      if (!uid || !object.subscription) return { userId: uid, ignored: true };
      const subscription = await stripe.subscriptions.retrieve(
        typeof object.subscription === 'string' ? object.subscription : object.subscription.id
      );
      applyStripeSubscriptionToAccount(data, uid, {
        ...stripeSubscriptionDetails(subscription),
        plan: object.metadata?.plan || stripeSubscriptionDetails(subscription).plan
      });
      return { userId: uid };
    }
    case 'customer.subscription.created':
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted': {
      const uid = object.metadata?.userId || object.metadata?.uid || null;
      if (!uid) return { userId: null, ignored: true };
      applyStripeSubscriptionToAccount(data, uid, stripeSubscriptionDetails(object));
      return { userId: uid };
    }
    case 'invoice.payment_succeeded':
    case 'invoice.payment_failed': {
      const subscriptionId = typeof object.subscription === 'string'
        ? object.subscription
        : object.subscription?.id || null;
      if (!subscriptionId) return { userId: null, ignored: true };
      const subscription = await stripe.subscriptions.retrieve(subscriptionId);
      const uid = subscription.metadata?.userId || object.metadata?.userId || null;
      if (!uid) return { userId: null, ignored: true };
      applyStripeSubscriptionToAccount(data, uid, stripeSubscriptionDetails(subscription));
      return { userId: uid };
    }
    default:
      return { userId: null, ignored: true };
  }
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

const supportedOcrLanguages = new Set([
  'auto',
  'ar',
  'en',
  'tr',
  'fr',
  'es',
  'de',
  'it',
  'pt',
  'zh-Hans',
  'zh-Hant',
  'ja',
  'ko',
  'hi',
  'ur',
  'id',
  'ms',
  'ru'
]);

function normalizeOcrLanguageHint(value) {
  const language = String(value || 'auto').trim();
  if (!language || language.toLowerCase() === 'auto') return 'auto';
  if (language === 'zh') return 'zh-Hans';
  return supportedOcrLanguages.has(language) ? language : null;
}

function ocrLanguageAccessForAccount(data, firebaseUser, languageHint) {
  const normalized = normalizeFeatureFlags(data.featureFlags);
  if (languageHint === 'auto' || languageHint === 'en') return { allowed: true };
  if (normalized.advancedOcrLanguagesEnabled !== true) {
    return { allowed: false, status: 400, error: 'OCR_LANGUAGE_NOT_SUPPORTED' };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (isAccountPremium(account, firebaseUser)) return { allowed: true };
  return { allowed: false, status: 403, error: 'PREMIUM_REQUIRED' };
}

function normalizeOcrModel(value) {
  const requested = String(value || 'read').trim().toLowerCase();
  if (requested === 'layout' || requested === azureDocumentIntelligence.layoutModel.toLowerCase()) {
    return azureDocumentIntelligence.layoutModel;
  }
  if (requested === 'read' || requested === azureDocumentIntelligence.readModel.toLowerCase()) {
    return azureDocumentIntelligence.readModel;
  }
  return null;
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

function decodePdfBase64(value, limits = pdfToExcelLimits) {
  if (typeof value !== 'string' || value.trim().isEmpty) return { error: 'INVALID_FILE' };
  const normalized = value.includes(',') ? value.split(',').pop() : value;
  if (!/^[a-zA-Z0-9+/=\r\n]+$/.test(normalized)) return { error: 'INVALID_FILE' };
  const pdfBuffer = Buffer.from(normalized, 'base64');
  if (!pdfBuffer.length) return { error: 'INVALID_FILE' };
  if (pdfBuffer.length > limits.maxPdfBytes) return { error: 'FILE_TOO_LARGE' };
  return { pdfBuffer };
}

function validatePdfBuffer(pdfBuffer, limits) {
  if (!Buffer.isBuffer(pdfBuffer) || !pdfBuffer.length) return { error: 'INVALID_FILE' };
  if (pdfBuffer.length > limits.maxPdfBytes) return { error: 'FILE_TOO_LARGE' };
  const header = pdfBuffer.subarray(0, 5).toString('utf8');
  if (header !== '%PDF-') return { error: 'INVALID_FILE' };
  return { pdfBuffer };
}

function parseMultipartBuffer(rawBody, contentType) {
  const match = /boundary=([^;]+)/i.exec(contentType || '');
  if (!match) return {};
  const boundary = `--${match[1]}`;
  const raw = rawBody.toString('binary');
  const parts = raw.split(boundary).slice(1, -1);
  const fields = {};
  for (const part of parts) {
    const separator = part.indexOf('\r\n\r\n');
    if (separator === -1) continue;
    const headers = part.slice(0, separator);
    let body = part.slice(separator + 4);
    if (body.endsWith('\r\n')) body = body.slice(0, -2);
    const name = /name="([^"]+)"/i.exec(headers)?.[1];
    if (!name) continue;
    const filename = /filename="([^"]*)"/i.exec(headers)?.[1];
    const mimeType = /content-type:\s*([^\r\n]+)/i.exec(headers)?.[1]?.trim();
    if (filename) {
      fields[name] = {
        filename,
        mimeType,
        buffer: Buffer.from(body, 'binary')
      };
    } else {
      fields[name] = Buffer.from(body, 'binary').toString('utf8');
    }
  }
  return fields;
}

async function readPdfConversionRequest(req, limits) {
  const contentType = String(req.headers['content-type'] || '');
  if (contentType.toLowerCase().startsWith('multipart/form-data')) {
    const raw = await readRawBody(req, { maxBytes: limits.maxBodyBytes });
    const fields = parseMultipartBuffer(raw, contentType);
    const filePart = fields.file || fields.pdf || fields.document;
    const decodedFile = validatePdfBuffer(filePart?.buffer, limits);
    if (decodedFile.error) {
      const error = new Error(decodedFile.error);
      error.code = decodedFile.error;
      throw error;
    }
    let options = {};
    if (typeof fields.options === 'string' && fields.options.trim()) {
      try {
        options = JSON.parse(fields.options);
      } catch (_) {
        options = {};
      }
    }
    return {
      documentId: fields.documentId ? String(fields.documentId) : '',
      fileName: fields.fileName ? String(fields.fileName) : filePart?.filename || 'document.pdf',
      options,
      pdfBuffer: decodedFile.pdfBuffer,
      mimeType: filePart?.mimeType || 'application/pdf'
    };
  }
  const body = await readBody(req, { maxBytes: limits.maxBodyBytes });
  const decoded = decodePdfBase64(body.pdfBase64, limits);
  if (decoded.error) {
    const error = new Error(decoded.error);
    error.code = decoded.error;
    throw error;
  }
  const validated = validatePdfBuffer(decoded.pdfBuffer, limits);
  if (validated.error) {
    const error = new Error(validated.error);
    error.code = validated.error;
    throw error;
  }
  return {
    documentId: body.documentId ? String(body.documentId) : '',
    fileName: body.fileName ? String(body.fileName) : 'document.pdf',
    options: body.options && typeof body.options === 'object' ? body.options : {},
    pdfBuffer: validated.pdfBuffer,
    mimeType: 'application/pdf'
  };
}

async function readPdfToExcelRequest(req) {
  return readPdfConversionRequest(req, pdfToExcelLimits);
}

async function readPdfToWordRequest(req) {
  return readPdfConversionRequest(req, pdfToWordLimits);
}

async function analyzeWithAzure({ imageBuffer, mimeType, model, languageHint, detectLanguage }) {
  const configError = validateAzureConfig();
  if (configError) {
    const error = new Error(configError);
    error.code = configError;
    throw error;
  }
  const endpoint = azureDocumentIntelligence.endpoint.endsWith('/')
    ? azureDocumentIntelligence.endpoint
    : `${azureDocumentIntelligence.endpoint}/`;
  const analyzeUrl = new URL(
    `documentintelligence/documentModels/${encodeURIComponent(model)}:analyze`,
    endpoint
  );
  analyzeUrl.searchParams.set('api-version', azureDocumentIntelligence.apiVersion);
  if (!detectLanguage && languageHint && languageHint !== 'auto') {
    analyzeUrl.searchParams.set('locale', languageHint);
  }
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 60000);
  try {
    const response = await fetch(analyzeUrl.toString(), {
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
    detectedLanguage: language,
    confidence
  };
}

function isProbablyArabic(text) {
  return /[\u0600-\u06FF]/.test(String(text || ''));
}

function safeSheetName(name, fallback) {
  const cleaned = String(name || fallback)
    .replace(/[\\/?*:[\]]/g, ' ')
    .trim()
    .slice(0, 31);
  return cleaned || fallback;
}

function extractLayoutTables(result) {
  const tables = Array.isArray(result.tables) ? result.tables : [];
  return tables.map((table, index) => {
    const rowCount = Number(table.rowCount || 0);
    const columnCount = Number(table.columnCount || 0);
    const rows = Array.from({ length: Math.max(rowCount, 1) }, () =>
      Array.from({ length: Math.max(columnCount, 1) }, () => '')
    );
    const cellMeta = [];
    for (const cell of table.cells || []) {
      const rowIndex = Number(cell.rowIndex || 0);
      const columnIndex = Number(cell.columnIndex || 0);
      if (rows[rowIndex] && columnIndex < rows[rowIndex].length) {
        rows[rowIndex][columnIndex] = String(cell.content || '');
      }
      cellMeta.push({
        rowIndex,
        columnIndex,
        rowSpan: Number(cell.rowSpan || 1),
        columnSpan: Number(cell.columnSpan || 1),
        kind: cell.kind || null,
        confidence: Number.isFinite(Number(cell.confidence)) ? Number(cell.confidence) : null
      });
    }
    const pageNumber = table.boundingRegions?.[0]?.pageNumber || null;
    const confidenceValues = cellMeta
      .map((item) => item.confidence)
      .filter((value) => Number.isFinite(value));
    const confidence = confidenceValues.length
      ? confidenceValues.reduce((sum, value) => sum + value, 0) / confidenceValues.length
      : null;
    return {
      index: index + 1,
      rowCount,
      columnCount,
      rows,
      cellMeta,
      pageNumber,
      confidence
    };
  });
}

function worksheetSetRtlIfNeeded(worksheet, text) {
  if (isProbablyArabic(text)) {
    worksheet.views = [{ rightToLeft: true }];
  }
}

async function buildExcelFromLayout({ result, fileName, options }) {
  const ExcelJS = require('exceljs');
  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'ScanLeno';
  workbook.created = new Date();
  workbook.modified = new Date();
  const tables = options.includeAllTables === false ? [] : extractLayoutTables(result);
  const pages = Array.isArray(result.pages) ? result.pages : [];
  const tablePageNumbers = tables.map((table) => Number(table.pageNumber || 0));
  const pagesProcessed = pages.length || (tablePageNumbers.length ? Math.max(...tablePageNumbers, 0) : 0);
  const summary = workbook.addWorksheet('Summary');
  summary.columns = [
    { header: 'Field', key: 'field', width: 28 },
    { header: 'Value', key: 'value', width: 48 }
  ];
  summary.addRows([
    { field: 'File name', value: fileName },
    { field: 'Tables count', value: tables.length },
    { field: 'Pages processed', value: pagesProcessed },
    { field: 'Converted at', value: new Date().toISOString() },
    { field: 'Provider', value: 'azure_document_intelligence' },
    { field: 'Model', value: azureDocumentIntelligence.layoutModel }
  ]);
  summary.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  summary.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0B2D5E' } };
  summary.views = [{ state: 'frozen', ySplit: 1, rightToLeft: isProbablyArabic(result.content) }];

  if (options.includeTextSheet !== false && result.content) {
    const textSheet = workbook.addWorksheet('Text');
    worksheetSetRtlIfNeeded(textSheet, result.content);
    textSheet.columns = [
      { header: 'Page', key: 'page', width: 10 },
      { header: 'Text', key: 'text', width: 120 }
    ];
    const paragraphs = String(result.content)
      .split(/\n{2,}|\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);
    if (paragraphs.length) {
      textSheet.addRows(paragraphs.map((text) => ({ page: '', text })));
    } else {
      textSheet.addRow({ page: '', text: String(result.content) });
    }
    textSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    textSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0B2D5E' } };
    textSheet.getColumn(2).alignment = { wrapText: true, vertical: 'top' };
    textSheet.views = [{ state: 'frozen', ySplit: 1, rightToLeft: isProbablyArabic(result.content) }];
  }

  if (tables.length === 0) {
    const empty = workbook.addWorksheet('Tables');
    empty.addRow(['No tables were detected in this document.']);
    empty.getCell('A1').font = { bold: true };
  } else if (options.oneTablePerSheet !== false) {
    for (const table of tables) {
      const sheetName = safeSheetName(`Table ${table.index}`, `Table ${table.index}`);
      const sheet = workbook.addWorksheet(sheetName);
      worksheetSetRtlIfNeeded(sheet, table.rows.flat().join(' '));
      sheet.addRow([`Table ${table.index}`, `Page ${table.pageNumber || ''}`, table.confidence == null ? '' : `Confidence ${(table.confidence * 100).toFixed(1)}%`]);
      sheet.addRows(table.rows);
      sheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
      sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0B2D5E' } };
      for (let row = 2; row <= table.rows.length + 1; row += 1) {
        sheet.getRow(row).alignment = { wrapText: true, vertical: 'top' };
      }
      sheet.columns.forEach((column) => {
        column.width = Math.min(45, Math.max(12, ...((column.values || []).map((value) => String(value || '').length + 2))));
      });
      sheet.views = [{ state: 'frozen', ySplit: 1, rightToLeft: isProbablyArabic(table.rows.flat().join(' ')) }];
    }
  } else {
    const sheet = workbook.addWorksheet('Tables');
    let currentRow = 1;
    for (const table of tables) {
      sheet.getRow(currentRow).values = [`Table ${table.index}`, `Page ${table.pageNumber || ''}`];
      sheet.getRow(currentRow).font = { bold: true, color: { argb: 'FFFFFFFF' } };
      sheet.getRow(currentRow).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0B2D5E' } };
      currentRow += 1;
      for (const row of table.rows) {
        sheet.getRow(currentRow).values = row;
        currentRow += 1;
      }
      currentRow += 2;
    }
    worksheetSetRtlIfNeeded(sheet, result.content);
  }

  for (const worksheet of workbook.worksheets) {
    worksheet.eachRow((row) => {
      row.eachCell((cell) => {
        cell.alignment = { ...(cell.alignment || {}), wrapText: true, vertical: 'top' };
        cell.border = {
          top: { style: 'thin', color: { argb: 'FFE5E7EB' } },
          left: { style: 'thin', color: { argb: 'FFE5E7EB' } },
          bottom: { style: 'thin', color: { argb: 'FFE5E7EB' } },
          right: { style: 'thin', color: { argb: 'FFE5E7EB' } }
        };
      });
    });
  }
  const buffer = await workbook.xlsx.writeBuffer();
  return {
    buffer: Buffer.from(buffer),
    tablesCount: tables.length,
    pagesProcessed
  };
}

function extractLayoutParagraphs(result) {
  const paragraphs = Array.isArray(result.paragraphs) ? result.paragraphs : [];
  if (paragraphs.length) {
    return paragraphs
      .map((paragraph, index) => ({
        index: index + 1,
        text: String(paragraph.content || '').trim(),
        role: paragraph.role || null,
        pageNumber: paragraph.boundingRegions?.[0]?.pageNumber || null
      }))
      .filter((paragraph) => paragraph.text);
  }
  const pages = Array.isArray(result.pages) ? result.pages : [];
  return pages.flatMap((page) => {
    const pageNumber = page.pageNumber || null;
    const lines = Array.isArray(page.lines) ? page.lines : [];
    return lines
      .map((line, index) => ({
        index: index + 1,
        text: String(line.content || '').trim(),
        role: null,
        pageNumber
      }))
      .filter((line) => line.text);
  });
}

function paragraphHeadingLevel(role, includeHeadings) {
  if (!includeHeadings) return undefined;
  const normalized = String(role || '').toLowerCase();
  if (normalized === 'title') return 'HEADING_1';
  if (normalized === 'sectionheading') return 'HEADING_2';
  return undefined;
}

function docxParagraph(text, options = {}) {
  const { Paragraph, TextRun, HeadingLevel, AlignmentType } = require('docx');
  const rtl = options.rtl ?? isProbablyArabic(text);
  const headingName = paragraphHeadingLevel(options.role, options.includeHeadings);
  return new Paragraph({
    bidirectional: rtl,
    alignment: rtl ? AlignmentType.RIGHT : AlignmentType.LEFT,
    heading: headingName ? HeadingLevel[headingName] : undefined,
    spacing: { after: options.after ?? 180 },
    children: [
      new TextRun({
        text,
        rightToLeft: rtl,
        bold: headingName != null
      })
    ]
  });
}

function docxTable(table) {
  const { Paragraph, Table, TableCell, TableRow, TextRun, WidthType } = require('docx');
  const rtl = isProbablyArabic(table.rows.flat().join(' '));
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: table.rows.map((row) =>
      new TableRow({
        children: row.map((cell) =>
          new TableCell({
            children: [
              new Paragraph({
                bidirectional: rtl,
                children: [
                  new TextRun({
                    text: String(cell || ''),
                    rightToLeft: rtl
                  })
                ]
              })
            ]
          })
        )
      })
    )
  });
}

async function buildWordFromLayout({ result, fileName, options }) {
  const { Document, Packer, Paragraph, PageBreak, TextRun } = require('docx');
  const paragraphs = options.preserveParagraphs === false
    ? String(result.content || '')
        .split(/\n{2,}|\r?\n/)
        .map((text, index) => ({ index: index + 1, text: text.trim(), role: null, pageNumber: null }))
        .filter((paragraph) => paragraph.text)
    : extractLayoutParagraphs(result);
  const tables = options.includeTables === false ? [] : extractLayoutTables(result);
  const pages = Array.isArray(result.pages) ? result.pages : [];
  const tablePageNumbers = tables.map((table) => Number(table.pageNumber || 0));
  const paragraphPageNumbers = paragraphs.map((paragraph) => Number(paragraph.pageNumber || 0));
  const pagesProcessed = pages.length ||
    Math.max(0, ...tablePageNumbers, ...paragraphPageNumbers);
  const contentText = paragraphs.map((paragraph) => paragraph.text).join('\n').trim();
  if (contentText.length < 3 && tables.length === 0) {
    const error = new Error('insufficient_text');
    error.code = 'INSUFFICIENT_TEXT';
    throw error;
  }
  const children = [
    new Paragraph({
      children: [
        new TextRun({ text: fileName.replace(/\.[^.]+$/, '') || 'ScanLeno Document', bold: true, size: 32 })
      ],
      spacing: { after: 240 }
    })
  ];

  if (options.includePageBreaks !== false && pagesProcessed > 1) {
    for (let page = 1; page <= pagesProcessed; page += 1) {
      const pageParagraphs = paragraphs.filter((paragraph) =>
        paragraph.pageNumber == null ? page === 1 : Number(paragraph.pageNumber) === page
      );
      const pageTables = tables.filter((table) =>
        table.pageNumber == null ? page === 1 : Number(table.pageNumber) === page
      );
      for (const paragraph of pageParagraphs) {
        children.push(docxParagraph(paragraph.text, {
          role: paragraph.role,
          includeHeadings: options.includeHeadings !== false,
          rtl: options.outputLanguageDirection === 'rtl'
            ? true
            : options.outputLanguageDirection === 'ltr'
              ? false
              : undefined
        }));
      }
      for (const table of pageTables) {
        children.push(docxParagraph(`Table ${table.index}`, { includeHeadings: true, role: 'sectionHeading' }));
        children.push(docxTable(table));
        children.push(new Paragraph({ text: '', spacing: { after: 180 } }));
      }
      if (page < pagesProcessed) {
        children.push(new Paragraph({ children: [new PageBreak()] }));
      }
    }
  } else {
    for (const paragraph of paragraphs) {
      children.push(docxParagraph(paragraph.text, {
        role: paragraph.role,
        includeHeadings: options.includeHeadings !== false,
        rtl: options.outputLanguageDirection === 'rtl'
          ? true
          : options.outputLanguageDirection === 'ltr'
            ? false
            : undefined
      }));
    }
    for (const table of tables) {
      children.push(docxParagraph(`Table ${table.index}`, { includeHeadings: true, role: 'sectionHeading' }));
      children.push(docxTable(table));
      children.push(new Paragraph({ text: '', spacing: { after: 180 } }));
    }
  }

  const document = new Document({
    creator: 'ScanLeno',
    description: 'Editable Word document generated by ScanLeno from Azure Document Intelligence layout extraction.',
    title: fileName.replace(/\.[^.]+$/, '') || 'ScanLeno Document',
    sections: [{ children }]
  });
  const buffer = await Packer.toBuffer(document);
  return {
    buffer,
    paragraphsCount: paragraphs.length,
    tablesCount: tables.length,
    pagesProcessed
  };
}

const supportedTranslateLanguages = [
  { code: 'ar', name: 'Arabic' },
  { code: 'en', name: 'English' },
  { code: 'tr', name: 'Turkish' },
  { code: 'fr', name: 'French' },
  { code: 'es', name: 'Spanish' },
  { code: 'de', name: 'German' },
  { code: 'zh-Hans', name: 'Chinese Simplified' },
  { code: 'ja', name: 'Japanese' },
  { code: 'ko', name: 'Korean' },
  { code: 'hi', name: 'Hindi' },
  { code: 'id', name: 'Indonesian' },
  { code: 'ur', name: 'Urdu' },
  { code: 'it', name: 'Italian' },
  { code: 'pt', name: 'Portuguese' }
];

function validateTranslatorConfig() {
  if (!azureTranslator.enabled) return 'AI_TRANSLATE_DISABLED';
  if (!azureTranslator.endpoint) return 'TRANSLATOR_ENDPOINT_MISSING';
  if (!azureTranslator.key) return 'TRANSLATOR_KEY_MISSING';
  return null;
}

function normalizeTranslateLanguage(value, { allowAuto = false } = {}) {
  const language = String(value || '').trim();
  if (allowAuto && (!language || language.toLowerCase() === 'auto')) return '';
  return supportedTranslateLanguages.some((item) => item.code === language) ? language : null;
}

function todayKey() {
  const now = new Date();
  return `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, '0')}-${String(now.getUTCDate()).padStart(2, '0')}`;
}

function translateAccessForAccount(data, firebaseUser) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  if (flags.translateEnabled !== true) {
    return { allowed: false, status: 403, error: 'AI_TRANSLATE_DISABLED', creditToConsume: false };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) {
    return { allowed: false, status: 401, error: 'AUTH_REQUIRED', creditToConsume: false, account };
  }
  const today = todayKey();
  if (account.dailyTranslateDay !== today) {
    account.dailyTranslateDay = today;
    account.dailyTranslateUsed = 0;
  }
  if (isAccountPremium(account, firebaseUser)) {
    const limit = Number(account.monthlyTranslateLimit || flags.premiumMonthlyTranslateLimit || 500);
    if (Number(account.monthlyTranslateUsed || 0) >= limit) {
      return { allowed: false, status: 429, error: 'TRANSLATE_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.translatePremiumOnly === false) {
    if (Number(account.dailyTranslateUsed || 0) >= Number(flags.freeDailyTranslateLimit || 3)) {
      return { allowed: false, status: 429, error: 'TRANSLATE_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.translateWithScanCreditEnabled !== false && Number(account.scanCredit || 0) > 0) {
    return { allowed: true, creditToConsume: true, account };
  }
  return {
    allowed: false,
    status: 403,
    error: flags.translateWithScanCreditEnabled !== false ? 'TRANSLATE_CREDIT_REQUIRED' : 'PREMIUM_REQUIRED',
    creditToConsume: false,
    account
  };
}

function updateTranslateUsageAfterSuccess(account, creditToConsume) {
  if (!account) return 0;
  const today = todayKey();
  if (account.dailyTranslateDay !== today) {
    account.dailyTranslateDay = today;
    account.dailyTranslateUsed = 0;
  }
  account.monthlyTranslateUsed = Number(account.monthlyTranslateUsed || 0) + 1;
  account.dailyTranslateUsed = Number(account.dailyTranslateUsed || 0) + 1;
  account.lastTranslateAt = new Date().toISOString();
  account.updatedAt = new Date().toISOString();
  if (creditToConsume) {
    account.scanCredit = Math.max(0, Number(account.scanCredit || 0) - 1);
  }
  return Number(account.scanCredit || 0);
}

function validateAiSummaryConfig() {
  if (!azureOpenAi.enabled) return 'AI_SUMMARY_DISABLED';
  if (!azureOpenAi.endpoint) return 'AI_PROVIDER_NOT_CONFIGURED';
  if (!azureOpenAi.key) return 'AI_PROVIDER_NOT_CONFIGURED';
  if (!azureOpenAi.deployment) return 'AI_PROVIDER_NOT_CONFIGURED';
  return null;
}

function normalizeSummaryLength(value) {
  const length = String(value || 'medium').trim().toLowerCase();
  return ['short', 'medium', 'detailed'].includes(length) ? length : null;
}

function normalizeSummaryLanguage(value) {
  const language = String(value || 'same').trim();
  return ['same', 'ar', 'en'].includes(language) ? language : null;
}

function aiSummaryAccessForAccount(data, firebaseUser) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  if (flags.aiSummaryEnabled !== true) {
    return { allowed: false, status: 403, error: 'AI_SUMMARY_DISABLED', creditToConsume: false };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) {
    return { allowed: false, status: 401, error: 'AUTH_REQUIRED', creditToConsume: false, account };
  }
  const today = todayKey();
  if (account.dailySummaryDay !== today) {
    account.dailySummaryDay = today;
    account.dailySummaryUsed = 0;
  }
  if (isAccountPremium(account, firebaseUser)) {
    const limit = Number(account.monthlySummaryLimit || flags.premiumMonthlySummaryLimit || 500);
    if (Number(account.monthlySummaryUsed || 0) >= limit) {
      return { allowed: false, status: 429, error: 'AI_SUMMARY_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.aiSummaryPremiumOnly === false) {
    if (Number(account.dailySummaryUsed || 0) >= Number(flags.freeDailySummaryLimit || 3)) {
      return { allowed: false, status: 429, error: 'AI_SUMMARY_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.aiSummaryWithScanCreditEnabled !== false && Number(account.scanCredit || 0) > 0) {
    return { allowed: true, creditToConsume: true, account };
  }
  return {
    allowed: false,
    status: 403,
    error: flags.aiSummaryWithScanCreditEnabled !== false ? 'AI_SUMMARY_CREDIT_REQUIRED' : 'PREMIUM_REQUIRED',
    creditToConsume: false,
    account
  };
}

function updateAiSummaryUsageAfterSuccess(account, creditToConsume) {
  if (!account) return 0;
  const today = todayKey();
  if (account.dailySummaryDay !== today) {
    account.dailySummaryDay = today;
    account.dailySummaryUsed = 0;
  }
  account.monthlySummaryUsed = Number(account.monthlySummaryUsed || 0) + 1;
  account.dailySummaryUsed = Number(account.dailySummaryUsed || 0) + 1;
  account.lastSummaryAt = new Date().toISOString();
  account.updatedAt = new Date().toISOString();
  if (creditToConsume) {
    account.scanCredit = Math.max(0, Number(account.scanCredit || 0) - 1);
  }
  return Number(account.scanCredit || 0);
}

function pdfToExcelAccessForAccount(data, firebaseUser) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  if (flags.pdfToExcelEnabled !== true) {
    return { allowed: false, status: 403, error: 'PDF_TO_EXCEL_DISABLED', creditToConsume: false };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) {
    return { allowed: false, status: 401, error: 'AUTH_REQUIRED', creditToConsume: false, account };
  }
  const today = todayKey();
  if (account.dailyPdfToExcelDay !== today) {
    account.dailyPdfToExcelDay = today;
    account.dailyPdfToExcelUsed = 0;
  }
  if (isAccountPremium(account, firebaseUser)) {
    const limit = Number(account.monthlyPdfToExcelLimit || flags.premiumMonthlyPdfToExcelLimit || 200);
    if (Number(account.monthlyPdfToExcelUsed || 0) >= limit) {
      return { allowed: false, status: 429, error: 'PDF_TO_EXCEL_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.pdfToExcelPremiumOnly === false) {
    if (Number(account.dailyPdfToExcelUsed || 0) >= Number(flags.freeDailyPdfToExcelLimit || 3)) {
      return { allowed: false, status: 429, error: 'PDF_TO_EXCEL_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.pdfToExcelWithScanCreditEnabled !== false && Number(account.scanCredit || 0) > 0) {
    return { allowed: true, creditToConsume: true, account };
  }
  return {
    allowed: false,
    status: 403,
    error: flags.pdfToExcelWithScanCreditEnabled !== false ? 'PDF_TO_EXCEL_CREDIT_REQUIRED' : 'PREMIUM_REQUIRED',
    creditToConsume: false,
    account
  };
}

function updatePdfToExcelUsageAfterSuccess(account, creditToConsume) {
  if (!account) return 0;
  const today = todayKey();
  if (account.dailyPdfToExcelDay !== today) {
    account.dailyPdfToExcelDay = today;
    account.dailyPdfToExcelUsed = 0;
  }
  account.monthlyPdfToExcelUsed = Number(account.monthlyPdfToExcelUsed || 0) + 1;
  account.dailyPdfToExcelUsed = Number(account.dailyPdfToExcelUsed || 0) + 1;
  account.lastPdfToExcelAt = new Date().toISOString();
  account.updatedAt = new Date().toISOString();
  if (creditToConsume) {
    account.scanCredit = Math.max(0, Number(account.scanCredit || 0) - 1);
  }
  return Number(account.scanCredit || 0);
}

function pdfToWordAccessForAccount(data, firebaseUser) {
  const flags = normalizeFeatureFlags(data.featureFlags);
  if (flags.pdfToWordEnabled !== true) {
    return { allowed: false, status: 403, error: 'PDF_TO_WORD_DISABLED', creditToConsume: false };
  }
  const account = findOrCreateAccount(data, firebaseUser);
  if (account.disabled === true) {
    return { allowed: false, status: 401, error: 'AUTH_REQUIRED', creditToConsume: false, account };
  }
  const today = todayKey();
  if (account.dailyPdfToWordDay !== today) {
    account.dailyPdfToWordDay = today;
    account.dailyPdfToWordUsed = 0;
  }
  if (isAccountPremium(account, firebaseUser)) {
    const limit = Number(account.monthlyPdfToWordLimit || flags.premiumMonthlyPdfToWordLimit || 200);
    if (Number(account.monthlyPdfToWordUsed || 0) >= limit) {
      return { allowed: false, status: 429, error: 'PDF_TO_WORD_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.pdfToWordPremiumOnly === false) {
    if (Number(account.dailyPdfToWordUsed || 0) >= Number(flags.freeDailyPdfToWordLimit || 3)) {
      return { allowed: false, status: 429, error: 'PDF_TO_WORD_LIMIT_REACHED', creditToConsume: false, account };
    }
    return { allowed: true, creditToConsume: false, account };
  }
  if (flags.pdfToWordWithScanCreditEnabled !== false && Number(account.scanCredit || 0) > 0) {
    return { allowed: true, creditToConsume: true, account };
  }
  return {
    allowed: false,
    status: 403,
    error: flags.pdfToWordWithScanCreditEnabled !== false ? 'PDF_TO_WORD_CREDIT_REQUIRED' : 'PREMIUM_REQUIRED',
    creditToConsume: false,
    account
  };
}

function updatePdfToWordUsageAfterSuccess(account, creditToConsume) {
  if (!account) return 0;
  const today = todayKey();
  if (account.dailyPdfToWordDay !== today) {
    account.dailyPdfToWordDay = today;
    account.dailyPdfToWordUsed = 0;
  }
  account.monthlyPdfToWordUsed = Number(account.monthlyPdfToWordUsed || 0) + 1;
  account.dailyPdfToWordUsed = Number(account.dailyPdfToWordUsed || 0) + 1;
  account.lastPdfToWordAt = new Date().toISOString();
  account.updatedAt = new Date().toISOString();
  if (creditToConsume) {
    account.scanCredit = Math.max(0, Number(account.scanCredit || 0) - 1);
  }
  return Number(account.scanCredit || 0);
}

function aiSummaryUrl() {
  const endpoint = azureOpenAi.endpoint.replace(/\/+$/, '');
  if (endpoint.endsWith('/openai/v1')) {
    return `${endpoint}/chat/completions`;
  }
  const deployment = encodeURIComponent(azureOpenAi.deployment);
  return `${endpoint}/openai/deployments/${deployment}/chat/completions?api-version=${encodeURIComponent(azureOpenAi.apiVersion)}`;
}

function summaryLengthInstruction(length) {
  return {
    short: 'Keep it concise: 3 to 5 bullets.',
    medium: 'Write a balanced summary with the key points and important details.',
    detailed: 'Write a detailed structured summary with sections and key takeaways.'
  }[length] || 'Write a balanced summary with the key points and important details.';
}

async function summarizeWithAzureOpenAi({ text, summaryLength, language }) {
  const configError = validateAiSummaryConfig();
  if (configError) {
    const error = new Error(configError);
    error.code = configError;
    throw error;
  }
  const languageInstruction = language === 'same'
    ? 'Use the same language as the source text.'
    : `Use ${language === 'ar' ? 'Arabic' : 'English'} for the summary.`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 45000);
  try {
    const response = await fetch(aiSummaryUrl(), {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'api-key': azureOpenAi.key
      },
      body: JSON.stringify({
        model: azureOpenAi.deployment || azureOpenAi.model,
        temperature: 0.2,
        messages: [
          {
            role: 'system',
            content: [
              'You are a document summarization assistant for ScanLeno.',
              'Summarize accurately using only the provided text.',
              'Do not add facts that are not present in the source text.',
              'If the text is unclear or incomplete, mention that briefly.',
              'Return a clean, structured summary.'
            ].join(' ')
          },
          {
            role: 'user',
            content: `${languageInstruction}\n${summaryLengthInstruction(summaryLength)}\n\nDocument text:\n${text}`
          }
        ]
      }),
      signal: controller.signal
    });
    if (response.status === 429) {
      const error = new Error('rate_limit');
      error.code = 'rate_limit';
      throw error;
    }
    if (!response.ok) {
      const error = new Error('ai_summary_failed');
      error.code = 'ai_summary_failed';
      throw error;
    }
    const payload = await response.json();
    const summary = String(payload.choices?.[0]?.message?.content || '').trim();
    if (!summary) {
      const error = new Error('empty_summary');
      error.code = 'empty_summary';
      throw error;
    }
    return {
      summary,
      provider: 'azure_openai',
      model: azureOpenAi.model,
      deployment: azureOpenAi.deployment,
      createdAt: new Date().toISOString()
    };
  } catch (error) {
    if (error.name === 'AbortError') error.code = 'timeout';
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

async function translateWithAzure({ text, fromLanguage, toLanguage }) {
  const configError = validateTranslatorConfig();
  if (configError) {
    const error = new Error(configError);
    error.code = configError;
    throw error;
  }
  const endpoint = azureTranslator.endpoint.endsWith('/')
    ? azureTranslator.endpoint
    : `${azureTranslator.endpoint}/`;
  const translateUrl = new URL('translate', endpoint);
  translateUrl.searchParams.set('api-version', '3.0');
  translateUrl.searchParams.set('to', toLanguage);
  if (fromLanguage) translateUrl.searchParams.set('from', fromLanguage);
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 30000);
  try {
    const response = await fetch(translateUrl, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'Ocp-Apim-Subscription-Key': azureTranslator.key,
        'Ocp-Apim-Subscription-Region': azureTranslator.region
      },
      body: JSON.stringify([{ text }]),
      signal: controller.signal
    });
    if (response.status === 429) {
      const error = new Error('rate_limit');
      error.code = 'rate_limit';
      throw error;
    }
    if (!response.ok) {
      const error = new Error('translate_failed');
      error.code = 'translate_failed';
      throw error;
    }
    const payload = await response.json();
    const first = Array.isArray(payload) ? payload[0] : null;
    const translation = first?.translations?.[0];
    return {
      translatedText: String(translation?.text || ''),
      sourceLanguage: fromLanguage || first?.detectedLanguage?.language || null,
      targetLanguage: toLanguage,
      provider: 'azure_translator',
      createdAt: new Date().toISOString()
    };
  } catch (error) {
    if (error.name === 'AbortError') error.code = 'timeout';
    throw error;
  } finally {
    clearTimeout(timeout);
  }
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
  if (req.method === 'GET' && url.pathname === '/api/stripe/config') {
    return send(res, 200, {
      stripeEnabled: stripeWeb.enabled,
      mode: stripeWeb.mode,
      publishableKey: stripeWeb.enabled ? stripeWeb.publishableKey : ''
    });
  }
  if (req.method === 'POST' && url.pathname === '/api/stripe/create-checkout-session') {
    if (!stripeWeb.enabled) return send(res, 403, { error: 'STRIPE_DISABLED' });
    const missing = stripeCheckoutMissingConfig();
    if (missing.length) return send(res, 503, { error: 'STRIPE_CONFIG_ERROR' });
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) return;
    let body;
    try {
      body = await readBody(req);
    } catch (_) {
      return send(res, 400, { error: 'invalid_json' });
    }
    const plan = String(body.plan || '').toLowerCase();
    if (!['monthly', 'yearly'].includes(plan)) return send(res, 400, { error: 'INVALID_PLAN' });
    const priceId = stripePlanPriceId(plan);
    if (!priceId) return send(res, 503, { error: 'STRIPE_CONFIG_ERROR' });
    try {
      const account = findOrCreateAccount(data, firebaseUser);
      if (account.disabled === true) return send(res, 401, { error: 'AUTH_REQUIRED' });
      const session = await stripeClient().checkout.sessions.create({
        mode: 'subscription',
        line_items: [{ price: priceId, quantity: 1 }],
        success_url: stripeWeb.successUrl,
        cancel_url: stripeWeb.cancelUrl,
        client_reference_id: firebaseUser.uid,
        customer_email: firebaseUser.email || undefined,
        metadata: {
          userId: firebaseUser.uid,
          source: 'scanleno_web',
          plan
        },
        subscription_data: {
          metadata: {
            userId: firebaseUser.uid,
            source: 'scanleno_web',
            plan
          }
        }
      });
      saveData(data);
      return send(res, 200, { checkoutUrl: session.url });
    } catch (error) {
      safeLog('stripe_checkout_failed', {
        status: 'failed',
        reason: error.code || 'checkout_failed',
        userId: firebaseUser.uid
      });
      return send(res, 502, { error: 'STRIPE_CHECKOUT_FAILED' });
    }
  }
  if (req.method === 'POST' && url.pathname === '/api/stripe/webhook') {
    if (!stripeWeb.enabled) return send(res, 403, { error: 'STRIPE_DISABLED' });
    if (!stripeWeb.webhookSecret || !stripeWeb.secretKey) {
      return send(res, 503, { error: 'STRIPE_CONFIG_ERROR' });
    }
    const requestId = crypto.randomUUID();
    let rawBody;
    try {
      rawBody = await readRawBody(req, { maxBytes: 1024 * 1024 });
    } catch (_) {
      return send(res, 413, { error: 'FILE_TOO_LARGE' });
    }
    let event;
    try {
      event = stripeClient().webhooks.constructEvent(
        rawBody,
        req.headers['stripe-signature'],
        stripeWeb.webhookSecret
      );
    } catch (_) {
      safeLog('stripe_webhook_rejected', {
        requestId,
        status: 'rejected',
        reason: 'signature_invalid'
      });
      return send(res, 400, { error: 'STRIPE_WEBHOOK_SIGNATURE_INVALID' });
    }
    try {
      const handled = await handleStripeEvent(stripeClient(), data, event);
      saveData(data);
      safeLog('stripe_webhook_processed', {
        requestId,
        status: handled.ignored ? 'ignored' : 'processed',
        userId: handled.userId,
        stripeEvent: event.type
      });
      return send(res, 200, { received: true });
    } catch (error) {
      safeLog('stripe_webhook_failed', {
        requestId,
        status: 'failed',
        reason: error.code || 'processing_failed',
        stripeEvent: event.type
      });
      return send(res, 500, { error: 'STRIPE_WEBHOOK_FAILED' });
    }
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
      azureOcrModel: azureDocumentIntelligence.readModel,
      azureOcrReadModel: azureDocumentIntelligence.readModel,
      azureOcrLayoutModel: azureDocumentIntelligence.layoutModel,
      translatorProvider: 'Azure Translator',
      translatorRegion: azureTranslator.region,
      azureTranslatorEnabled: azureTranslator.enabled && !validateTranslatorConfig(),
      aiSummaryProvider: 'Azure OpenAI',
      aiSummaryModel: azureOpenAi.model,
      aiSummaryDeployment: azureOpenAi.deployment,
      azureOpenAiSummaryEnabled: azureOpenAi.enabled && !validateAiSummaryConfig(),
      pdfToWordProvider: 'Azure Document Intelligence',
      pdfToWordModel: azureDocumentIntelligence.layoutModel
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
    if (body.monthlyTranslateLimit !== undefined) adminFields.monthlyTranslateLimit = Number(body.monthlyTranslateLimit);
    if (body.monthlyTranslateUsed !== undefined) adminFields.monthlyTranslateUsed = Number(body.monthlyTranslateUsed);
    if (body.dailyTranslateUsed !== undefined) adminFields.dailyTranslateUsed = Number(body.dailyTranslateUsed);
    if (body.monthlySummaryLimit !== undefined) adminFields.monthlySummaryLimit = Number(body.monthlySummaryLimit);
    if (body.monthlySummaryUsed !== undefined) adminFields.monthlySummaryUsed = Number(body.monthlySummaryUsed);
    if (body.dailySummaryUsed !== undefined) adminFields.dailySummaryUsed = Number(body.dailySummaryUsed);
    if (body.monthlyPdfToExcelLimit !== undefined) adminFields.monthlyPdfToExcelLimit = Number(body.monthlyPdfToExcelLimit);
    if (body.monthlyPdfToExcelUsed !== undefined) adminFields.monthlyPdfToExcelUsed = Number(body.monthlyPdfToExcelUsed);
    if (body.dailyPdfToExcelUsed !== undefined) adminFields.dailyPdfToExcelUsed = Number(body.dailyPdfToExcelUsed);
    if (body.monthlyPdfToWordLimit !== undefined) adminFields.monthlyPdfToWordLimit = Number(body.monthlyPdfToWordLimit);
    if (body.monthlyPdfToWordUsed !== undefined) adminFields.monthlyPdfToWordUsed = Number(body.monthlyPdfToWordUsed);
    if (body.dailyPdfToWordUsed !== undefined) adminFields.dailyPdfToWordUsed = Number(body.dailyPdfToWordUsed);
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
        monthlyTranslateUsed: Number(existing.monthlyTranslateUsed || 0),
        monthlyTranslateLimit: Number(existing.monthlyTranslateLimit || 0),
        dailyTranslateUsed: Number(existing.dailyTranslateUsed || 0),
        dailyTranslateDay: existing.dailyTranslateDay || null,
        lastTranslateAt: existing.lastTranslateAt || null,
        monthlySummaryUsed: Number(existing.monthlySummaryUsed || 0),
        monthlySummaryLimit: Number(existing.monthlySummaryLimit || 0),
        dailySummaryUsed: Number(existing.dailySummaryUsed || 0),
        dailySummaryDay: existing.dailySummaryDay || null,
        lastSummaryAt: existing.lastSummaryAt || null,
        monthlyPdfToExcelUsed: Number(existing.monthlyPdfToExcelUsed || 0),
        monthlyPdfToExcelLimit: Number(existing.monthlyPdfToExcelLimit || 0),
        dailyPdfToExcelUsed: Number(existing.dailyPdfToExcelUsed || 0),
        dailyPdfToExcelDay: existing.dailyPdfToExcelDay || null,
        lastPdfToExcelAt: existing.lastPdfToExcelAt || null,
        monthlyPdfToWordUsed: Number(existing.monthlyPdfToWordUsed || 0),
        monthlyPdfToWordLimit: Number(existing.monthlyPdfToWordLimit || 0),
        dailyPdfToWordUsed: Number(existing.dailyPdfToWordUsed || 0),
        dailyPdfToWordDay: existing.dailyPdfToWordDay || null,
        lastPdfToWordAt: existing.lastPdfToWordAt || null,
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
  if (req.method === 'GET' && url.pathname === '/api/translate/languages') {
    return send(res, 200, {
      languages: supportedTranslateLanguages,
      autoDetect: true,
      provider: azureTranslator.provider
    });
  }
  if (req.method === 'POST' && url.pathname === '/api/translate/text') {
    const requestId = crypto.randomUUID();
    if (!rateLimit(req, 'translate_ip', azureTranslator.perIpPerMinute, 60 * 1000)) {
      safeLog('translate_rejected', { requestId, status: 'rate_limited', reason: 'ip' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) {
      safeLog('translate_rejected', { requestId, status: 'rejected', reason: 'auth' });
      return;
    }
    if (!rateLimitValue('translate_user', firebaseUser.uid, azureTranslator.perUserPerMinute, 60 * 1000)) {
      safeLog('translate_rejected', { requestId, status: 'rate_limited', reason: 'user' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    let body;
    try {
      body = await readBody(req, { maxBytes: azureTranslator.maxTextChars * 4 + 2048 });
    } catch (_) {
      return send(res, 400, { error: 'INVALID_TEXT' });
    }
    const text = String(body.text || '').trim();
    if (!text) return send(res, 400, { error: 'INVALID_TEXT' });
    if (text.length > azureTranslator.maxTextChars) return send(res, 413, { error: 'INVALID_TEXT' });
    const toLanguage = normalizeTranslateLanguage(body.toLanguage);
    const fromLanguage = normalizeTranslateLanguage(body.fromLanguage, { allowAuto: true });
    if (!toLanguage || fromLanguage === null) return send(res, 400, { error: 'INVALID_LANGUAGE' });
    const configError = validateTranslatorConfig();
    if (configError) return send(res, 503, { error: configError === 'AI_TRANSLATE_DISABLED' ? 'AI_TRANSLATE_DISABLED' : 'AI_PROVIDER_NOT_CONFIGURED' });
    const access = translateAccessForAccount(data, firebaseUser);
    if (!access.allowed) {
      safeLog('translate_rejected', { requestId, status: 'rejected', reason: access.error });
      return send(res, access.status || 403, { error: access.error });
    }
    try {
      const translated = await translateWithAzure({ text, fromLanguage, toLanguage });
      const remainingScanCredit = updateTranslateUsageAfterSuccess(access.account, access.creditToConsume);
      saveData(data);
      safeLog('translate_success', {
        requestId,
        status: 'translated',
        reason: translated.sourceLanguage || 'auto',
        userId: firebaseUser.uid
      });
      return send(res, 200, {
        documentId: body.documentId ? String(body.documentId) : null,
        pageIndex: Number(body.pageIndex || 0),
        sourceLanguage: translated.sourceLanguage,
        targetLanguage: translated.targetLanguage,
        translatedText: translated.translatedText,
        provider: translated.provider,
        createdAt: translated.createdAt,
        creditConsumed: access.creditToConsume,
        remainingScanCredit
      });
    } catch (error) {
      const code = error.code || 'translate_failed';
      safeLog('translate_failed', { requestId, status: 'failed', reason: code, userId: firebaseUser.uid });
      if (code === 'rate_limit') return send(res, 429, { error: 'RATE_LIMITED' });
      if (code === 'timeout') return send(res, 504, { error: 'AI_TRANSLATE_FAILED' });
      if (code === 'TRANSLATOR_KEY_MISSING' || code === 'TRANSLATOR_ENDPOINT_MISSING') {
        return send(res, 503, { error: 'AI_PROVIDER_NOT_CONFIGURED' });
      }
      return send(res, 502, { error: 'AI_TRANSLATE_FAILED' });
    }
  }
  if (req.method === 'POST' && (url.pathname === '/api/ai/summary' || url.pathname === '/api/ai/summary-from-ocr')) {
    const requestId = crypto.randomUUID();
    if (!rateLimit(req, 'ai_summary_ip', azureOpenAi.perIpPerMinute, 60 * 1000)) {
      safeLog('ai_summary_rejected', { requestId, status: 'rate_limited', reason: 'ip' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) {
      safeLog('ai_summary_rejected', { requestId, status: 'rejected', reason: 'auth' });
      return;
    }
    if (!rateLimitValue('ai_summary_user', firebaseUser.uid, azureOpenAi.perUserPerMinute, 60 * 1000)) {
      safeLog('ai_summary_rejected', { requestId, status: 'rate_limited', reason: 'user' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    let body;
    try {
      body = await readBody(req, { maxBytes: azureOpenAi.maxTextChars * 4 + 2048 });
    } catch (_) {
      return send(res, 400, { error: 'INVALID_TEXT' });
    }
    const text = String(body.text || body.ocrText || '').trim();
    if (!text) return send(res, 400, { error: 'INVALID_TEXT' });
    if (text.length > azureOpenAi.maxTextChars) return send(res, 413, { error: 'INVALID_TEXT' });
    const summaryLength = normalizeSummaryLength(body.summaryLength);
    const language = normalizeSummaryLanguage(body.language);
    if (!summaryLength) return send(res, 400, { error: 'INVALID_SUMMARY_LENGTH' });
    if (!language) return send(res, 400, { error: 'INVALID_TEXT' });
    const configError = validateAiSummaryConfig();
    if (configError) return send(res, 503, { error: configError });
    const access = aiSummaryAccessForAccount(data, firebaseUser);
    if (!access.allowed) {
      safeLog('ai_summary_rejected', { requestId, status: 'rejected', reason: access.error });
      return send(res, access.status || 403, { error: access.error });
    }
    try {
      const result = await summarizeWithAzureOpenAi({ text, summaryLength, language });
      const remainingScanCredit = updateAiSummaryUsageAfterSuccess(access.account, access.creditToConsume);
      saveData(data);
      safeLog('ai_summary_success', {
        requestId,
        status: 'summarized',
        userId: firebaseUser.uid,
        reason: summaryLength
      });
      return send(res, 200, {
        documentId: body.documentId ? String(body.documentId) : null,
        pageIndex: Number(body.pageIndex || 0),
        sourceLanguage: body.sourceLanguage ? String(body.sourceLanguage) : null,
        summaryLanguage: language,
        originalTextLength: text.length,
        summary: result.summary,
        summaryLength,
        provider: result.provider,
        model: result.model,
        deployment: result.deployment,
        createdAt: result.createdAt,
        creditConsumed: access.creditToConsume,
        remainingScanCredit
      });
    } catch (error) {
      const code = error.code || 'ai_summary_failed';
      safeLog('ai_summary_failed', { requestId, status: 'failed', reason: code, userId: firebaseUser.uid });
      if (code === 'rate_limit') return send(res, 429, { error: 'RATE_LIMITED' });
      if (code === 'timeout') return send(res, 504, { error: 'AI_SUMMARY_FAILED' });
      if (code === 'AI_PROVIDER_NOT_CONFIGURED' || code.endsWith('_MISSING')) return send(res, 503, { error: 'AI_PROVIDER_NOT_CONFIGURED' });
      return send(res, 502, { error: 'AI_SUMMARY_FAILED' });
    }
  }
  if (req.method === 'POST' && url.pathname === '/api/pdf/to-excel') {
    const requestId = crypto.randomUUID();
    if (!rateLimit(req, 'pdf_to_excel_ip', pdfToExcelLimits.perIpPerMinute, 60 * 1000)) {
      safeLog('pdf_to_excel_rejected', { requestId, status: 'rate_limited', reason: 'ip' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) {
      safeLog('pdf_to_excel_rejected', { requestId, status: 'rejected', reason: 'auth' });
      return;
    }
    if (!rateLimitValue('pdf_to_excel_user', firebaseUser.uid, pdfToExcelLimits.perUserPerMinute, 60 * 1000)) {
      safeLog('pdf_to_excel_rejected', { requestId, status: 'rate_limited', reason: 'user' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const access = pdfToExcelAccessForAccount(data, firebaseUser);
    if (!access.allowed) {
      safeLog('pdf_to_excel_rejected', { requestId, status: 'rejected', reason: access.error });
      return send(res, access.status || 403, { error: access.error });
    }
    let payload;
    try {
      payload = await readPdfToExcelRequest(req);
    } catch (error) {
      const code = error.code === 'FILE_TOO_LARGE' ? 'FILE_TOO_LARGE' : 'INVALID_FILE';
      return send(res, code === 'FILE_TOO_LARGE' ? 413 : 400, { error: code });
    }
    if (!payload.pdfBuffer || payload.mimeType !== 'application/pdf') {
      return send(res, 415, { error: 'INVALID_FILE' });
    }
    const configError = validateAzureConfig();
    if (configError) return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
    try {
      const result = await analyzeWithAzure({
        imageBuffer: payload.pdfBuffer,
        mimeType: 'application/pdf',
        model: azureDocumentIntelligence.layoutModel,
        languageHint: 'auto',
        detectLanguage: true
      });
      const excel = await buildExcelFromLayout({
        result,
        fileName: payload.fileName,
        options: {
          includeAllTables: payload.options.includeAllTables !== false,
          includeTextSheet: payload.options.includeTextSheet !== false,
          oneTablePerSheet: payload.options.oneTablePerSheet !== false,
          preserveCellText: payload.options.preserveCellText !== false
        }
      });
      const remainingScanCredit = updatePdfToExcelUsageAfterSuccess(access.account, access.creditToConsume);
      saveData(data);
      safeLog('pdf_to_excel_success', {
        requestId,
        status: 'converted',
        userId: firebaseUser.uid,
        reason: `tables:${excel.tablesCount}`
      });
      const baseName = String(payload.fileName || 'document.pdf').replace(/\.[^.]+$/, '') || 'document';
      return send(res, 200, {
        documentId: payload.documentId,
        fileName: `${baseName}.xlsx`,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        excelBase64: excel.buffer.toString('base64'),
        tablesCount: excel.tablesCount,
        pagesProcessed: excel.pagesProcessed,
        provider: 'azure_document_intelligence',
        model: azureDocumentIntelligence.layoutModel,
        createdAt: new Date().toISOString(),
        creditConsumed: access.creditToConsume,
        remainingScanCredit
      });
    } catch (error) {
      const code = error.code || 'pdf_to_excel_failed';
      safeLog('pdf_to_excel_failed', { requestId, status: 'failed', reason: code, userId: firebaseUser.uid });
      if (code === 'rate_limit') return send(res, 429, { error: 'RATE_LIMITED' });
      if (code === 'timeout') return send(res, 504, { error: 'PDF_TO_EXCEL_FAILED' });
      if (code === 'azure_key_missing' || code === 'azure_endpoint_missing') {
        return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
      }
      return send(res, 502, { error: 'PDF_TO_EXCEL_FAILED' });
    }
  }
  if (req.method === 'POST' && url.pathname === '/api/pdf/to-word') {
    const requestId = crypto.randomUUID();
    if (!rateLimit(req, 'pdf_to_word_ip', pdfToWordLimits.perIpPerMinute, 60 * 1000)) {
      safeLog('pdf_to_word_rejected', { requestId, status: 'rate_limited', reason: 'ip' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const firebaseUser = await requireFirebaseUser(req, res);
    if (!firebaseUser) {
      safeLog('pdf_to_word_rejected', { requestId, status: 'rejected', reason: 'auth' });
      return;
    }
    if (!rateLimitValue('pdf_to_word_user', firebaseUser.uid, pdfToWordLimits.perUserPerMinute, 60 * 1000)) {
      safeLog('pdf_to_word_rejected', { requestId, status: 'rate_limited', reason: 'user' });
      return send(res, 429, { error: 'RATE_LIMITED' });
    }
    const access = pdfToWordAccessForAccount(data, firebaseUser);
    if (!access.allowed) {
      safeLog('pdf_to_word_rejected', { requestId, status: 'rejected', reason: access.error });
      return send(res, access.status || 403, { error: access.error });
    }
    let payload;
    try {
      payload = await readPdfToWordRequest(req);
    } catch (error) {
      const code = error.code === 'FILE_TOO_LARGE' ? 'FILE_TOO_LARGE' : 'INVALID_FILE';
      return send(res, code === 'FILE_TOO_LARGE' ? 413 : 400, { error: code });
    }
    if (!payload.pdfBuffer || payload.mimeType !== 'application/pdf') {
      return send(res, 415, { error: 'INVALID_FILE' });
    }
    const configError = validateAzureConfig();
    if (configError) return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
    try {
      const result = await analyzeWithAzure({
        imageBuffer: payload.pdfBuffer,
        mimeType: 'application/pdf',
        model: azureDocumentIntelligence.layoutModel,
        languageHint: 'auto',
        detectLanguage: true
      });
      const word = await buildWordFromLayout({
        result,
        fileName: payload.fileName,
        options: {
          preserveParagraphs: payload.options.preserveParagraphs !== false,
          includeTables: payload.options.includeTables !== false,
          includePageBreaks: payload.options.includePageBreaks !== false,
          includeHeadings: payload.options.includeHeadings !== false,
          outputLanguageDirection: ['auto', 'rtl', 'ltr'].includes(payload.options.outputLanguageDirection)
            ? payload.options.outputLanguageDirection
            : 'auto'
        }
      });
      const remainingScanCredit = updatePdfToWordUsageAfterSuccess(access.account, access.creditToConsume);
      saveData(data);
      safeLog('pdf_to_word_success', {
        requestId,
        status: 'converted',
        userId: firebaseUser.uid,
        reason: `paragraphs:${word.paragraphsCount};tables:${word.tablesCount}`
      });
      const baseName = String(payload.fileName || 'document.pdf').replace(/\.[^.]+$/, '') || 'document';
      return send(res, 200, {
        documentId: payload.documentId,
        fileName: `${baseName}.docx`,
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        docxBase64: word.buffer.toString('base64'),
        pagesProcessed: word.pagesProcessed,
        paragraphsCount: word.paragraphsCount,
        tablesCount: word.tablesCount,
        provider: 'azure_document_intelligence',
        model: azureDocumentIntelligence.layoutModel,
        createdAt: new Date().toISOString(),
        creditConsumed: access.creditToConsume,
        remainingScanCredit
      });
    } catch (error) {
      const code = error.code || 'pdf_to_word_failed';
      safeLog('pdf_to_word_failed', { requestId, status: 'failed', reason: code, userId: firebaseUser.uid });
      if (code === 'rate_limit') return send(res, 429, { error: 'RATE_LIMITED' });
      if (code === 'INSUFFICIENT_TEXT') return send(res, 422, { error: 'INSUFFICIENT_TEXT' });
      if (code === 'timeout') return send(res, 504, { error: 'PDF_TO_WORD_FAILED' });
      if (code === 'azure_key_missing' || code === 'azure_endpoint_missing') {
        return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
      }
      return send(res, 502, { error: 'PDF_TO_WORD_FAILED' });
    }
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
    const languageHint = normalizeOcrLanguageHint(body.languageHint || data.featureFlags.defaultOcrLanguage);
    if (!languageHint) return send(res, 400, { error: 'OCR_LANGUAGE_NOT_SUPPORTED' });
    const languageAccess = ocrLanguageAccessForAccount(data, firebaseUser, languageHint);
    if (!languageAccess.allowed) return send(res, languageAccess.status || 403, { error: languageAccess.error });
    const selectedModel = normalizeOcrModel(body.model);
    if (!selectedModel) return send(res, 400, { error: 'INVALID_OCR_MODEL' });
    const detectLanguage = body.detectLanguage === true || languageHint === 'auto';
    const decoded = decodeOcrImage(body);
    if (decoded.error) return send(res, decoded.error === 'FILE_TOO_LARGE' ? 413 : 400, { error: decoded.error });
    const configError = validateAzureConfig();
    if (configError) return send(res, 503, { error: 'SERVER_CONFIG_ERROR' });
    try {
      const result = await analyzeWithAzure({
        imageBuffer: decoded.imageBuffer,
        mimeType,
        model: selectedModel,
        languageHint,
        detectLanguage
      });
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
        detectedLanguage: extracted.detectedLanguage,
        languageHint,
        confidence: extracted.confidence,
        provider: 'azure_document_intelligence',
        model: selectedModel,
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

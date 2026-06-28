# ScanLeno production environment

ScanLeno must not use localhost defaults in production. Production builds must
pass an explicit backend URL with Dart defines.

## Flutter production defines

Required:

- `SCANLENO_ENV=production`
- `SCANLENO_BACKEND_URL=https://your-production-backend.example.com`

Optional/product configuration:

- `SCANLENO_IAP_MONTHLY_ID=scanleno_premium_monthly`
- `SCANLENO_IAP_ANNUAL_ID=scanleno_premium_yearly`
- `SCANLENO_AD_BANNER_ID`
- `SCANLENO_AD_INTERSTITIAL_ID`
- `SCANLENO_AD_REWARDED_ID`

Example Android production build:

```powershell
flutter build appbundle --release `
  --dart-define=SCANLENO_ENV=production `
  --dart-define=SCANLENO_BACKEND_URL=https://api.scanleno.com
```

Example iOS production build:

```powershell
flutter build ipa --release `
  --dart-define=SCANLENO_ENV=production `
  --dart-define=SCANLENO_BACKEND_URL=https://api.scanleno.com
```

Development may omit `SCANLENO_BACKEND_URL`; in that case Flutter uses
`http://localhost:8787`. Staging and production must not omit it.

## Backend production variables

Required:

- `NODE_ENV=production` or `SCANLENO_ENV=production`
- `FIREBASE_PROJECT_ID=scanleno-37d42`
- `SCANLENO_ALLOWED_ORIGINS=https://app.scanleno.com`
- `AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT`
- `AZURE_DOCUMENT_INTELLIGENCE_KEY`
- `AZURE_DOCUMENT_INTELLIGENCE_MODEL=prebuilt-layout`
- `AZURE_DOCUMENT_INTELLIGENCE_API_VERSION=2024-11-30`

Recommended:

- `SCANLENO_API_TOKEN` for operational/admin integrations
- `SCANLENO_DATA_FILE` pointing to persistent storage

AdMob rewarded SSV:

- `ADMOB_SSV_ENABLED=true`
- `ADMOB_SSV_PUBLIC_KEYS_URL=https://www.gstatic.com/admob/reward/verifier-keys.json`
- `ADMOB_REWARDED_ANDROID_AD_UNIT_ID=ca-app-pub-5375559288118322/3373021373`
- `ADMOB_REWARDED_IOS_AD_UNIT_ID=ca-app-pub-5375559288118322/7312266382`
- `SCANLENO_ENABLE_DEV_REWARDED_CREDIT=false`
- `REWARDED_CREDIT_ITEM=scan_credit`
- `REWARDED_CREDIT_AMOUNT=1`
- `REWARDED_CUSTOM_DATA_SECRET`

Do not store Azure keys, store credentials, or service account JSON files in
Flutter code or public repositories.

If the backend runs outside Google Cloud, Firebase Admin may need a secure
service account configuration through environment variables, the host secret
manager, or a mounted secret path. Do not commit service account JSON files or
real credentials to Git.

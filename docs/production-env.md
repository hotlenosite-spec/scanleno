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
- `AZURE_DOCUMENT_INTELLIGENCE_MODEL=prebuilt-read`
- `AZURE_DOCUMENT_INTELLIGENCE_READ_MODEL=prebuilt-read`
- `AZURE_DOCUMENT_INTELLIGENCE_LAYOUT_MODEL=prebuilt-layout`
- `AZURE_DOCUMENT_INTELLIGENCE_API_VERSION=2024-11-30`

Azure Translator, when translation is enabled:

- `AZURE_TRANSLATOR_ENABLED=true`
- `AZURE_TRANSLATOR_ENDPOINT=https://api.cognitive.microsofttranslator.com/`
- `AZURE_TRANSLATOR_REGION=global`
- `AZURE_TRANSLATOR_KEY`
- `SCANLENO_TRANSLATE_MAX_TEXT_CHARS=10000`
- `SCANLENO_TRANSLATE_USER_RATE_LIMIT_PER_MINUTE=20`
- `SCANLENO_TRANSLATE_IP_RATE_LIMIT_PER_MINUTE=40`

Azure OpenAI / Azure AI Foundry, when AI Summary is enabled:

- `AZURE_AI_SUMMARY_ENABLED=true`
- `AZURE_AI_PROJECT_ENDPOINT`
- `AZURE_OPENAI_ENDPOINT=https://scanleno-ai-summary.openai.azure.com/openai/v1`
- `AZURE_OPENAI_DEPLOYMENT=scanleno-gpt-4o-mini`
- `AZURE_OPENAI_MODEL=gpt-4o-mini`
- `AZURE_OPENAI_API_VERSION=2024-12-01-preview`
- `AZURE_OPENAI_KEY`
- `SCANLENO_AI_SUMMARY_MAX_TEXT_CHARS=12000`
- `SCANLENO_AI_SUMMARY_USER_RATE_LIMIT_PER_MINUTE=10`
- `SCANLENO_AI_SUMMARY_IP_RATE_LIMIT_PER_MINUTE=20`

If the `scanleno-gpt-4o-mini` deployment does not exist in Azure AI Foundry,
create a deployment with that name or update `AZURE_OPENAI_DEPLOYMENT` in the
backend environment. Do not put Azure OpenAI keys in Flutter or Git.

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

Stripe Web subscriptions:

- `STRIPE_WEB_ENABLED=true` only for ScanLeno Web subscription checkout
- `STRIPE_MODE=live`
- `STRIPE_SECRET_KEY` from backend secrets only
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_SCANLENO_MONTHLY_PRICE_ID`
- `STRIPE_SCANLENO_YEARLY_PRICE_ID`
- `STRIPE_SUCCESS_URL`
- `STRIPE_CANCEL_URL`

Stripe is not used for mobile subscriptions. iOS uses Apple In-App Purchase,
and Android uses Google Play Billing. See `docs/stripe-web-env.md`.

Do not store Azure keys, store credentials, or service account JSON files in
Flutter code or public repositories.

If the backend runs outside Google Cloud, Firebase Admin may need a secure
service account configuration through environment variables, the host secret
manager, or a mounted secret path. Do not commit service account JSON files or
real credentials to Git.

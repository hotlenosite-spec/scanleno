# Premium tools environment

These tools are protected by Firebase ID token verification and backend-side
Premium checks. Do not put provider keys in Flutter code or commit real secrets.

## AI Summary

- `AI_FEATURES_ENABLED=false`
- `AI_PROVIDER=`
- `AI_API_KEY=`
- `AI_SUMMARY_MODEL=`

The current backend maps these generic variables to the Azure OpenAI summary
provider. If disabled or not configured, the API returns a structured error
instead of a mock summary.

## AI Translate

- `AI_TRANSLATE_ENABLED=false`
- `AI_TRANSLATE_PROVIDER=`
- `AI_TRANSLATE_MODEL=`

The current backend uses Azure Translator configuration for the actual provider
credentials. If disabled or not configured, the API returns a structured error
instead of a mock translation.

## PDF conversions

- `PDF_TO_WORD_ENABLED=false`
- `PDF_TO_EXCEL_ENABLED=false`

PDF conversion uses Azure Document Intelligence layout analysis plus local
document builders. Requests are size-limited, PDF-only, authenticated, and
Premium-gated.

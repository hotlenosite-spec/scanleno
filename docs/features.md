# ScanLeno Features

ScanLeno provides local-first document scanning, gallery import, edge adjustment, enhancement filters, PDF/JPG export, file management, signatures, premium gating, ad placement controls, OCR feature flags, and an admin/back-office foundation.

Free mode is limited by feature flags and may show ads. Premium mode removes ads and unlocks higher limits when official store verification is configured.

## Accounts

ScanLeno supports Firebase Authentication for account identity while keeping documents local.

- Guest users can continue with anonymous/local use.
- Registered users can sign in with Email/Password, Google, or Apple.
- Firestore is limited to `users/{uid}` metadata for profile, plan, premium state, scan credits, OCR counters, disabled state, and role.
- Premium, OCR, and admin/backend requests can use Firebase ID tokens for authorization.
- Firebase Storage is not part of the document workflow.

AdMob support includes banner, interstitial, and rewarded placements through the official Google Mobile Ads SDK. Rewarded ads can grant one local `scan_credit`.

## OCR

ScanLeno OCR is implemented through the backend using Azure Document Intelligence.

- Provider: Azure Document Intelligence.
- Model: `prebuilt-read`.
- Flutter sends only the selected page/image to `POST /api/ocr/analyze`.
- Premium users can run OCR directly.
- Free users can run OCR only when they have one local `scan_credit` from a rewarded ad.
- After successful OCR, the backend returns structured text, lines, words, language, confidence, provider, model, and creation time.
- The app saves OCR text and metadata in Drift/SQLite linked to the local document/page.
- OCR keys and Azure configuration are backend-only environment variables.

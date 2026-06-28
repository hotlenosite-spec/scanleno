# ScanLeno

ScanLeno is a production-oriented Flutter document scanning and PDF workflow app for Android, iOS, and Web.

## Core principles

- Local-first document handling.
- No paid services required by default.
- No user document upload to the backend by default.
- Arabic and English localization with RTL/LTR support.
- Central design tokens, theme, feature flags, premium, ads, and admin foundations.

## Run

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run -d chrome
```

Android builds require Android SDK. iOS release builds require macOS and Xcode.

## Local database

ScanLeno uses Drift/SQLite for local metadata:

- documents and file paths
- folders
- trash/favorite state
- saved signatures
- local settings and usage limits
- optional OCR text linked to a document

PDF and image bytes stay as files on the device; the database stores metadata and paths only.

For Web, Drift uses an IndexedDB backend. Bundle `sql.js` locally in `web/` for production web runtime persistence; do not rely on a third-party CDN for privacy-sensitive builds.

## Runtime configuration

Pass product IDs, ad unit IDs, and backend URL with Dart defines:

```bash
flutter run --dart-define=SCANLENO_IAP_MONTHLY_ID=scanleno_premium_monthly
```

Never commit secrets or production ad unit IDs directly into source code.

## Firebase Authentication and Firestore metadata

ScanLeno uses Firebase for accounts only:

- Firebase Authentication supports anonymous/guest use, Email/Password, Google, and Apple sign-in.
- Firestore stores only account metadata under `users/{uid}`.
- Firestore metadata includes plan status, premium state, scan credits, OCR usage counters, role, and safe profile fields.
- User documents, PDFs, images, OCR image bytes, OCR document content, and local file paths are never stored in Firestore.
- Firebase Storage is intentionally not used.
- Sensitive backend calls can be authorized with a Firebase ID token.

Firestore rules are documented in `docs/firebase-security-rules.md` and provided in `firebase/firestore.rules`.

## Google AdMob

ScanLeno integrates the official `google_mobile_ads` Flutter SDK.

- Debug builds use Google test ad unit IDs.
- Release builds use the configured production AdMob unit IDs.
- Android App ID: `ca-app-pub-5375559288118322~5149137479`
- iOS App ID: `ca-app-pub-5375559288118322~8298044990`
- Banner ads appear only on Home, Files, and Tools.
- Interstitial ads are shown only after a successful export.
- Rewarded ads grant `1 scan_credit` with reward item `scan_credit`.
- Premium users never see ads.
- Ads are not shown inside camera, edge adjustment, or document preview workflows.

AdMob IDs are not passwords, but they are centralized in `AdMobConfig` for safe platform/debug/release switching.

## Backend

A small self-hosted Node.js backend is available in `backend/`.

```bash
cd backend
cp .env.example .env
node server.js
```

It stores minimal metadata only and does not receive user documents by default.

## Azure Document Intelligence OCR

OCR is routed through the backend only. Flutter never contains the Azure key.

- Put Azure values in `backend/.env`; never commit that file.
- `AZURE_DOCUMENT_INTELLIGENCE_KEY` must stay server-side.
- OCR sends only the selected page/image requested by the user.
- The backend forwards that page to Azure Document Intelligence using `prebuilt-layout`.
- The backend does not save uploaded OCR images.
- The extracted text is returned to the app and saved locally in Drift/SQLite with OCR metadata.
- Premium users can use OCR. Free users can use OCR only when they have one rewarded `scan_credit`.

Example:

```bash
cd backend
cp .env.example .env
# Fill AZURE_DOCUMENT_INTELLIGENCE_KEY in backend/.env only.
node server.js
flutter run -d chrome --dart-define=SCANLENO_BACKEND_URL=http://localhost:8787
```

## Documentation

- `docs/features.md`
- `docs/privacy-notes.md`
- `docs/admin-dashboard.md`
- `docs/production-checklist.md`

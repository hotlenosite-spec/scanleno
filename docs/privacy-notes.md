# ScanLeno Privacy Notes

- Documents stay on the user's device by default.
- The backend does not receive document images or PDFs by default.
- Firebase is used for account identity and safe subscription/usage metadata only.
- Firestore stores `users/{uid}` metadata such as plan, premium state, role, scan credits, and OCR counters.
- Firestore must not store PDFs, images, OCR image bytes, document text, full document contents, or local file paths.
- Firebase Storage is intentionally not used for ScanLeno documents.
- OCR sends only the single page/image selected by the user to the backend for processing.
- OCR processing forwards that selected page to Azure Document Intelligence and does not upload the user's full document library.
- OCR images are not saved in the backend.
- Extracted OCR text is returned to the app and stored locally in Drift/SQLite on the user's device.
- Admin views must show usage metadata only, not document contents.
- App errors must not include document text, image bytes, or PDF contents.
- Secrets, store credentials, and ad unit IDs must be provided through environment/configuration.
- File deletion requires user confirmation and supports local trash before permanent deletion.
- SQLite stores metadata, local file paths, settings, usage counters, saved signature vectors, and optional OCR text. PDF/image bytes remain files on-device and are not stored as database blobs.
- AdMob is used only for ad delivery. ScanLeno does not upload user documents to AdMob or any backend.
- Azure Document Intelligence credentials must live only in `backend/.env`; never in Flutter, admin HTML, or committed source files.

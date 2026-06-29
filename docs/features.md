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

## Watermark

Watermark processing is local-first and uses the app's existing PDF/image stack.

- Image/JPG files can be watermarked locally and saved as a new `_watermarked` copy.
- PDF exports created from scanned/imported pages can include a real watermark in the generated PDF file.
- Existing PDF files are not uploaded or modified in place; create a watermarked PDF through Save & Export from document pages.
- Free exports can receive the default ScanLeno watermark when `exportWatermarkEnabled` and `freeExportWatermarkRequired` are enabled.
- Premium users are not forced to use the default watermark and can add an optional custom watermark when `premiumCustomWatermarkEnabled` is enabled.
- Admin feature flags control `watermarkEnabled`, `exportWatermarkEnabled`, `freeExportWatermarkRequired`, `defaultWatermarkText`, `defaultWatermarkOpacity`, `defaultWatermarkPosition`, and `premiumCustomWatermarkEnabled`.

## OCR

ScanLeno OCR is implemented through the backend using Azure Document Intelligence.

- Provider: Azure Document Intelligence.
- Models: `prebuilt-read` for standard OCR and `prebuilt-layout` for layout/table extraction.
- Flutter sends only the selected page/image to `POST /api/ocr/analyze`.
- Advanced OCR languages support Auto Detect, Arabic, English, Turkish, French, Spanish, German, Italian, Portuguese, Chinese Simplified, Chinese Traditional, Japanese, Korean, Hindi, Urdu, Indonesian, Malay, and Russian.
- When a user selects a specific OCR language, the backend passes it as a language hint to Azure Document Intelligence. Auto Detect sends no language hint.
- Premium users can run OCR directly.
- Free users can run OCR only when they have one local `scan_credit` from a rewarded ad.
- After successful OCR, the backend returns structured text, lines, words, language, confidence, provider, model, and creation time.
- The app saves OCR text and metadata in Drift/SQLite linked to the local document/page.
- OCR keys and Azure configuration are backend-only environment variables.

## AI Translate

ScanLeno translation is implemented through the backend using Azure Translator.

- Flutter sends selected text only to `POST /api/translate/text`.
- The app never sends the full PDF/image file for translation.
- Text can come from saved OCR text, locally saved document metadata, or manual user input.
- Premium users can translate within the monthly translation limit.
- Free users can translate only when translation is not Premium-only, or when scan-credit access is enabled and they have one `scan_credit`.
- `scan_credit` is consumed only after a successful translation response.
- Translation results are saved locally in Drift/SQLite when linked to a document.
- Azure Translator keys and configuration are backend-only environment variables.

## AI Document Summary

ScanLeno document summarization is implemented through the backend using Azure OpenAI / Azure AI Foundry.

- Flutter sends selected text only to `POST /api/ai/summary` or saved OCR text to `POST /api/ai/summary-from-ocr`.
- The app never sends a full PDF, image file, or document library for summarization.
- Text can come from saved OCR text in Drift/SQLite or manual user input.
- Premium users can summarize within the monthly summary limit.
- Free users can summarize only when AI Summary is not Premium-only, or when scan-credit access is enabled and they have one `scan_credit`.
- `scan_credit` is consumed only after a successful Azure OpenAI summary response.
- Summary length supports `short`, `medium`, and `detailed`.
- Summary language supports same-as-document, Arabic, and English.
- Summaries are saved locally in Drift/SQLite when linked to a document.
- Azure OpenAI keys and deployment configuration are backend-only environment variables.

## PDF to Excel

ScanLeno converts PDF tables to `.xlsx` through the backend using Azure Document Intelligence `prebuilt-layout`.

- Flutter sends only the selected PDF to `POST /api/pdf/to-excel`.
- The backend forwards the selected PDF temporarily to Azure Document Intelligence for layout/table extraction.
- The backend does not save the original PDF.
- Extracted tables are written into a real XLSX workbook generated in the backend with `exceljs`.
- The workbook includes a `Summary` sheet, one sheet per table when enabled, and an optional text sheet.
- Arabic and English cell text is preserved where Azure returns it.
- The resulting XLSX file is returned to the app, saved locally, registered in Drift/SQLite, and can be shared.
- Free/Premium access and `scan_credit` are enforced by the backend before Azure is called.

## PDF to Word

ScanLeno converts PDF files to editable `.docx` documents through the backend using Azure Document Intelligence `prebuilt-layout`.

- Flutter sends only the selected PDF to `POST /api/pdf/to-word`.
- The backend forwards the selected PDF temporarily to Azure Document Intelligence for layout extraction.
- The backend does not save the original PDF or log document contents.
- The backend extracts paragraphs, lines, words, tables, page numbers, and available layout metadata.
- The backend generates a real DOCX file with the `docx` Node.js library.
- The generated Word document preserves paragraphs where possible, can include page breaks, and includes tables when enabled.
- Arabic and English text are supported, with automatic RTL handling for Arabic content.
- The resulting DOCX file is returned to the app, saved locally, registered in Drift/SQLite, and can be shared.
- Free/Premium access and `scan_credit` are enforced by the backend before Azure is called.

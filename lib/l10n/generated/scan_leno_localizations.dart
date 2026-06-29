import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'scan_leno_localizations_ar.dart';
import 'scan_leno_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ScanLenoLocalizations
/// returned by `ScanLenoLocalizations.of(context)`.
///
/// Applications need to include `ScanLenoLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/scan_leno_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ScanLenoLocalizations.localizationsDelegates,
///   supportedLocales: ScanLenoLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ScanLenoLocalizations.supportedLocales
/// property.
abstract class ScanLenoLocalizations {
  ScanLenoLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ScanLenoLocalizations? of(BuildContext context) {
    return Localizations.of<ScanLenoLocalizations>(
      context,
      ScanLenoLocalizations,
    );
  }

  static const LocalizationsDelegate<ScanLenoLocalizations> delegate =
      _ScanLenoLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ScanLeno'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @ocr.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition'**
  String get ocr;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @ads.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// No description provided for @pageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This area is being prepared.'**
  String get pageComingSoon;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access to document tools'**
  String get quickAccess;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan Document'**
  String get scanDocument;

  /// No description provided for @startNewScan.
  ///
  /// In en, this message translates to:
  /// **'Start a new scan'**
  String get startNewScan;

  /// No description provided for @importFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Import from gallery'**
  String get importFromGallery;

  /// No description provided for @recentDocuments.
  ///
  /// In en, this message translates to:
  /// **'Recent documents'**
  String get recentDocuments;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @noDocumentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your scanned and imported documents will appear here.'**
  String get noDocumentsDescription;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @myFiles.
  ///
  /// In en, this message translates to:
  /// **'My Files'**
  String get myFiles;

  /// No description provided for @searchFiles.
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get searchFiles;

  /// No description provided for @allFiles.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFiles;

  /// No description provided for @pdfFiles.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfFiles;

  /// No description provided for @imageFiles.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get imageFiles;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sortBySize;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @folderContracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get folderContracts;

  /// No description provided for @folderInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get folderInvoices;

  /// No description provided for @folderIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get folderIdentity;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get deleteFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get moveToFolder;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFromFavorites;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @deleteFolderWarning.
  ///
  /// In en, this message translates to:
  /// **'Files will stay saved, but the folder will be removed.'**
  String get deleteFolderWarning;

  /// No description provided for @deleteFileWarning.
  ///
  /// In en, this message translates to:
  /// **'Move this file to trash?'**
  String get deleteFileWarning;

  /// No description provided for @deleteForeverWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the file from this device.'**
  String get deleteForeverWarning;

  /// No description provided for @noTrashItems.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get noTrashItems;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @imagesToPdf.
  ///
  /// In en, this message translates to:
  /// **'Image to PDF'**
  String get imagesToPdf;

  /// No description provided for @mergePdf.
  ///
  /// In en, this message translates to:
  /// **'Merge PDF'**
  String get mergePdf;

  /// No description provided for @compressPdf.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get compressPdf;

  /// No description provided for @editPdf.
  ///
  /// In en, this message translates to:
  /// **'Edit PDF'**
  String get editPdf;

  /// No description provided for @signPdf.
  ///
  /// In en, this message translates to:
  /// **'Sign Document'**
  String get signPdf;

  /// No description provided for @extractText.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition'**
  String get extractText;

  /// No description provided for @moreTools.
  ///
  /// In en, this message translates to:
  /// **'More tools'**
  String get moreTools;

  /// No description provided for @smartAssistant.
  ///
  /// In en, this message translates to:
  /// **'Smart Assistant'**
  String get smartAssistant;

  /// No description provided for @smartAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Analyze documents, summarize content, and answer questions'**
  String get smartAssistantDescription;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try now'**
  String get tryNow;

  /// No description provided for @splitPdf.
  ///
  /// In en, this message translates to:
  /// **'Split PDF'**
  String get splitPdf;

  /// No description provided for @protectPdf.
  ///
  /// In en, this message translates to:
  /// **'Protect with password'**
  String get protectPdf;

  /// No description provided for @removePages.
  ///
  /// In en, this message translates to:
  /// **'Remove pages'**
  String get removePages;

  /// No description provided for @reorderPages.
  ///
  /// In en, this message translates to:
  /// **'Reorder pages'**
  String get reorderPages;

  /// No description provided for @rotatePdfPages.
  ///
  /// In en, this message translates to:
  /// **'Rotate PDF pages'**
  String get rotatePdfPages;

  /// No description provided for @pdfToImages.
  ///
  /// In en, this message translates to:
  /// **'PDF to Images'**
  String get pdfToImages;

  /// No description provided for @multipleImagesToPdf.
  ///
  /// In en, this message translates to:
  /// **'Multiple Images to PDF'**
  String get multipleImagesToPdf;

  /// No description provided for @addTextToPdf.
  ///
  /// In en, this message translates to:
  /// **'Add text to PDF'**
  String get addTextToPdf;

  /// No description provided for @addWatermark.
  ///
  /// In en, this message translates to:
  /// **'Add watermark'**
  String get addWatermark;

  /// No description provided for @printDocument.
  ///
  /// In en, this message translates to:
  /// **'Print document'**
  String get printDocument;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get searchDocuments;

  /// No description provided for @lockDocument.
  ///
  /// In en, this message translates to:
  /// **'Lock document'**
  String get lockDocument;

  /// No description provided for @duplicateDocument.
  ///
  /// In en, this message translates to:
  /// **'Duplicate document'**
  String get duplicateDocument;

  /// No description provided for @manageFiles.
  ///
  /// In en, this message translates to:
  /// **'Manage files'**
  String get manageFiles;

  /// No description provided for @toolUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This tool is prepared but not enabled yet.'**
  String get toolUnavailable;

  /// No description provided for @cropDocument.
  ///
  /// In en, this message translates to:
  /// **'Edge Adjustment'**
  String get cropDocument;

  /// No description provided for @adjustEdges.
  ///
  /// In en, this message translates to:
  /// **'Adjust the corners to fit your document.'**
  String get adjustEdges;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @detectEdges.
  ///
  /// In en, this message translates to:
  /// **'Detect edges'**
  String get detectEdges;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @noDocumentPages.
  ///
  /// In en, this message translates to:
  /// **'No document pages selected yet.'**
  String get noDocumentPages;

  /// No description provided for @openScanner.
  ///
  /// In en, this message translates to:
  /// **'Open scanner'**
  String get openScanner;

  /// No description provided for @enhanceDocument.
  ///
  /// In en, this message translates to:
  /// **'Enhance Document'**
  String get enhanceDocument;

  /// No description provided for @chooseFilter.
  ///
  /// In en, this message translates to:
  /// **'Choose a filter'**
  String get chooseFilter;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @enhancedFilter.
  ///
  /// In en, this message translates to:
  /// **'Enhanced'**
  String get enhancedFilter;

  /// No description provided for @blackAndWhite.
  ///
  /// In en, this message translates to:
  /// **'B&W'**
  String get blackAndWhite;

  /// No description provided for @gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get gray;

  /// No description provided for @colored.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colored;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveAndExport.
  ///
  /// In en, this message translates to:
  /// **'Save & Export'**
  String get saveAndExport;

  /// No description provided for @previewDocument.
  ///
  /// In en, this message translates to:
  /// **'Document preview'**
  String get previewDocument;

  /// No description provided for @addPages.
  ///
  /// In en, this message translates to:
  /// **'Add pages'**
  String get addPages;

  /// No description provided for @documentName.
  ///
  /// In en, this message translates to:
  /// **'Document name'**
  String get documentName;

  /// No description provided for @fileFormat.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get fileFormat;

  /// No description provided for @pdfDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfDocument;

  /// No description provided for @imageFormat.
  ///
  /// In en, this message translates to:
  /// **'JPG'**
  String get imageFormat;

  /// No description provided for @jpg.
  ///
  /// In en, this message translates to:
  /// **'JPG'**
  String get jpg;

  /// No description provided for @saveToFiles.
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get saveToFiles;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveDocument.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveDocument;

  /// No description provided for @pageSize.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get pageSize;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @passwordProtection.
  ///
  /// In en, this message translates to:
  /// **'Password protection'**
  String get passwordProtection;

  /// No description provided for @ocrExtraction.
  ///
  /// In en, this message translates to:
  /// **'Text extraction OCR'**
  String get ocrExtraction;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @a4.
  ///
  /// In en, this message translates to:
  /// **'A4'**
  String get a4;

  /// No description provided for @letter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letter;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @originalSize.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get originalSize;

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pageCount;

  /// No description provided for @pagesUnit.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get pagesUnit;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @deletePage.
  ///
  /// In en, this message translates to:
  /// **'Delete page'**
  String get deletePage;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumFeature;

  /// No description provided for @passwordProtectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password protection is coming soon.'**
  String get passwordProtectionComingSoon;

  /// No description provided for @ocrComingSoon.
  ///
  /// In en, this message translates to:
  /// **'OCR is optional and not enabled yet.'**
  String get ocrComingSoon;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully.'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the document.'**
  String get saveFailed;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the document.'**
  String get shareFailed;

  /// No description provided for @signDocument.
  ///
  /// In en, this message translates to:
  /// **'Sign Document'**
  String get signDocument;

  /// No description provided for @addSignature.
  ///
  /// In en, this message translates to:
  /// **'Add signature'**
  String get addSignature;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @signatureHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in the area above'**
  String get signatureHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @applySignature.
  ///
  /// In en, this message translates to:
  /// **'Apply signature'**
  String get applySignature;

  /// No description provided for @saveSignature.
  ///
  /// In en, this message translates to:
  /// **'Save signature'**
  String get saveSignature;

  /// No description provided for @saveSignedDocument.
  ///
  /// In en, this message translates to:
  /// **'Save signed document'**
  String get saveSignedDocument;

  /// No description provided for @signatureSaved.
  ///
  /// In en, this message translates to:
  /// **'Signature saved.'**
  String get signatureSaved;

  /// No description provided for @signedDocumentSaved.
  ///
  /// In en, this message translates to:
  /// **'Signed document saved.'**
  String get signedDocumentSaved;

  /// No description provided for @noSavedSignatures.
  ///
  /// In en, this message translates to:
  /// **'No saved signatures yet.'**
  String get noSavedSignatures;

  /// No description provided for @deleteSignature.
  ///
  /// In en, this message translates to:
  /// **'Delete signature'**
  String get deleteSignature;

  /// No description provided for @savedSignatures.
  ///
  /// In en, this message translates to:
  /// **'Saved signatures'**
  String get savedSignatures;

  /// No description provided for @signatureColor.
  ///
  /// In en, this message translates to:
  /// **'Signature color'**
  String get signatureColor;

  /// No description provided for @editingTools.
  ///
  /// In en, this message translates to:
  /// **'Editing tools'**
  String get editingTools;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @resize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get resize;

  /// No description provided for @ocrResult.
  ///
  /// In en, this message translates to:
  /// **'Extracted text'**
  String get ocrResult;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// No description provided for @exportText.
  ///
  /// In en, this message translates to:
  /// **'Export text'**
  String get exportText;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share text'**
  String get shareText;

  /// No description provided for @searchText.
  ///
  /// In en, this message translates to:
  /// **'Search text'**
  String get searchText;

  /// No description provided for @textSaved.
  ///
  /// In en, this message translates to:
  /// **'Text saved.'**
  String get textSaved;

  /// No description provided for @textReady.
  ///
  /// In en, this message translates to:
  /// **'Your text is ready to review and edit.'**
  String get textReady;

  /// No description provided for @recognitionComplete.
  ///
  /// In en, this message translates to:
  /// **'Text recognition complete'**
  String get recognitionComplete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced features and more storage'**
  String get premiumDescription;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get upgradeNow;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyPlan;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annualPlan;

  /// No description provided for @premiumMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Premium'**
  String get premiumMonthly;

  /// No description provided for @premiumAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual Premium'**
  String get premiumAnnual;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @premiumFreeFeature1.
  ///
  /// In en, this message translates to:
  /// **'Limited daily scans'**
  String get premiumFreeFeature1;

  /// No description provided for @premiumFreeFeature2.
  ///
  /// In en, this message translates to:
  /// **'Basic filters and standard export'**
  String get premiumFreeFeature2;

  /// No description provided for @premiumFreeFeature3.
  ///
  /// In en, this message translates to:
  /// **'Ads may appear'**
  String get premiumFreeFeature3;

  /// No description provided for @premiumFeature1.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get premiumFeature1;

  /// No description provided for @premiumFeature2.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans and imports'**
  String get premiumFeature2;

  /// No description provided for @premiumFeature3.
  ///
  /// In en, this message translates to:
  /// **'High-quality export and advanced PDF tools'**
  String get premiumFeature3;

  /// No description provided for @premiumFeature4.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumFeature4;

  /// No description provided for @premiumRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumRequiredTitle;

  /// No description provided for @premiumRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature requires an active ScanLeno Premium subscription.'**
  String get premiumRequiredMessage;

  /// No description provided for @freeDailyScanLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached today’s free scan limit. Subscribe to keep scanning without daily limits.'**
  String get freeDailyScanLimitReached;

  /// No description provided for @freeFolderLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the free folder limit. Subscribe to organize more folders.'**
  String get freeFolderLimitReached;

  /// No description provided for @premiumRequiredForAdvancedPdf.
  ///
  /// In en, this message translates to:
  /// **'Advanced PDF tools are included with ScanLeno Premium.'**
  String get premiumRequiredForAdvancedPdf;

  /// No description provided for @premiumRequiredForUnlimitedScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans and imports are included with ScanLeno Premium.'**
  String get premiumRequiredForUnlimitedScans;

  /// No description provided for @premiumRequiredForOcr.
  ///
  /// In en, this message translates to:
  /// **'Text recognition is available with Premium, or with one OCR credit from a rewarded ad.'**
  String get premiumRequiredForOcr;

  /// No description provided for @subscribeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to continue'**
  String get subscribeToContinue;

  /// No description provided for @unlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium features'**
  String get unlockPremiumFeatures;

  /// No description provided for @watchAdForOneOcrCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one OCR credit'**
  String get watchAdForOneOcrCredit;

  /// No description provided for @premiumSubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get premiumSubscribeNow;

  /// No description provided for @premiumMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get premiumMaybeLater;

  /// No description provided for @premiumOcrCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'You can use one scan credit for this OCR request. The credit is only consumed after successful text recognition.'**
  String get premiumOcrCreditMessage;

  /// No description provided for @premiumOcrNoCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'OCR is available for Premium users, or you can watch a rewarded ad to earn one OCR credit.'**
  String get premiumOcrNoCreditMessage;

  /// No description provided for @premiumFeatureLocked.
  ///
  /// In en, this message translates to:
  /// **'Feature unavailable'**
  String get premiumFeatureLocked;

  /// No description provided for @premiumFeatureLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently disabled and cannot be opened right now.'**
  String get premiumFeatureLockedMessage;

  /// No description provided for @premiumUnlockAdvancedTools.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock advanced PDF tools.'**
  String get premiumUnlockAdvancedTools;

  /// No description provided for @subscriptionCached.
  ///
  /// In en, this message translates to:
  /// **'Subscription will be verified by the store/backend when configured.'**
  String get subscriptionCached;

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscription is not available right now.'**
  String get subscriptionUnavailable;

  /// No description provided for @subscriptionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions will be enabled soon.'**
  String get subscriptionComingSoon;

  /// No description provided for @subscriptionProductsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store products were not found yet.'**
  String get subscriptionProductsNotFound;

  /// No description provided for @subscriptionPurchaseStarted.
  ///
  /// In en, this message translates to:
  /// **'Purchase started. Complete it in the store.'**
  String get subscriptionPurchaseStarted;

  /// No description provided for @subscriptionPurchasePending.
  ///
  /// In en, this message translates to:
  /// **'Purchase is pending confirmation.'**
  String get subscriptionPurchasePending;

  /// No description provided for @subscriptionVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Purchase received. Premium will activate after verification.'**
  String get subscriptionVerificationPending;

  /// No description provided for @subscriptionPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get subscriptionPurchaseFailed;

  /// No description provided for @subscriptionPurchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase was cancelled.'**
  String get subscriptionPurchaseCancelled;

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get subscriptionRestoreSuccess;

  /// No description provided for @subscriptionRestoreNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No active purchases were found.'**
  String get subscriptionRestoreNothingFound;

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active.'**
  String get subscriptionActive;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has expired.'**
  String get subscriptionExpired;

  /// No description provided for @premiumMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly plan'**
  String get premiumMonthlyPlan;

  /// No description provided for @premiumYearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly plan'**
  String get premiumYearlyPlan;

  /// No description provided for @premiumPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get premiumPriceUnavailable;

  /// No description provided for @premiumStoreNotReady.
  ///
  /// In en, this message translates to:
  /// **'Store is not ready yet.'**
  String get premiumStoreNotReady;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @adPlacement.
  ///
  /// In en, this message translates to:
  /// **'Ad placement'**
  String get adPlacement;

  /// No description provided for @earnScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Earn scan credit'**
  String get earnScanCredit;

  /// No description provided for @scanCreditReward.
  ///
  /// In en, this message translates to:
  /// **'Watch a rewarded ad to add one scan credit.'**
  String get scanCreditReward;

  /// No description provided for @watchAdForOcrCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for OCR credit'**
  String get watchAdForOcrCredit;

  /// No description provided for @rewardedAdNotReady.
  ///
  /// In en, this message translates to:
  /// **'Rewarded ad is not ready yet.'**
  String get rewardedAdNotReady;

  /// No description provided for @rewardedCreditPending.
  ///
  /// In en, this message translates to:
  /// **'Your reward is being verified.'**
  String get rewardedCreditPending;

  /// No description provided for @rewardedCreditGranted.
  ///
  /// In en, this message translates to:
  /// **'OCR credit confirmed.'**
  String get rewardedCreditGranted;

  /// No description provided for @rewardedCreditRejected.
  ///
  /// In en, this message translates to:
  /// **'Reward verification was rejected.'**
  String get rewardedCreditRejected;

  /// No description provided for @rewardedCreditExpired.
  ///
  /// In en, this message translates to:
  /// **'Reward session expired. Please try again.'**
  String get rewardedCreditExpired;

  /// No description provided for @rewardedVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the reward. Please try again.'**
  String get rewardedVerificationFailed;

  /// No description provided for @ocrCreditAdded.
  ///
  /// In en, this message translates to:
  /// **'One OCR credit was added.'**
  String get ocrCreditAdded;

  /// No description provided for @ocrCreditRequired.
  ///
  /// In en, this message translates to:
  /// **'One OCR credit is required.'**
  String get ocrCreditRequired;

  /// No description provided for @premiumOrRewardRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscribe or watch a rewarded ad to use OCR.'**
  String get premiumOrRewardRequired;

  /// No description provided for @rewardEarnedWaitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Reward earned. Waiting for server verification.'**
  String get rewardEarnedWaitingForVerification;

  /// No description provided for @rewardedSsvNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Reward verification is not configured yet.'**
  String get rewardedSsvNotConfigured;

  /// No description provided for @rewardedLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Reward limit reached. Please try again later.'**
  String get rewardedLimitReached;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin login'**
  String get adminLogin;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboard;

  /// No description provided for @adminRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get adminRoles;

  /// No description provided for @adminStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get adminStats;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get adminSubscriptions;

  /// No description provided for @adminFlags.
  ///
  /// In en, this message translates to:
  /// **'Feature Flags'**
  String get adminFlags;

  /// No description provided for @adminAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get adminAds;

  /// No description provided for @adminSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get adminSupport;

  /// No description provided for @adminMessages.
  ///
  /// In en, this message translates to:
  /// **'App messages'**
  String get adminMessages;

  /// No description provided for @adminPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy controls'**
  String get adminPrivacy;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get activeUsers;

  /// No description provided for @scanCount.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get scanCount;

  /// No description provided for @createdPdfCount.
  ///
  /// In en, this message translates to:
  /// **'Created PDFs'**
  String get createdPdfCount;

  /// No description provided for @freeUsers.
  ///
  /// In en, this message translates to:
  /// **'Free users'**
  String get freeUsers;

  /// No description provided for @premiumUsers.
  ///
  /// In en, this message translates to:
  /// **'Premium users'**
  String get premiumUsers;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @filesStayOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Files stay on your device by default.'**
  String get filesStayOnDevice;

  /// No description provided for @usedStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get usedStorage;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'26% used'**
  String get storageUsage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan documents.'**
  String get cameraPermissionDescription;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get changesSaved;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @couldNotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Could not load data.'**
  String get couldNotLoadData;

  /// No description provided for @restoreRequested.
  ///
  /// In en, this message translates to:
  /// **'Restore request sent.'**
  String get restoreRequested;

  /// No description provided for @restorePurchasesDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your purchase status again.'**
  String get restorePurchasesDescription;

  /// No description provided for @accountSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get accountSubscription;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get accountPreferences;

  /// No description provided for @languageManagedBySystem.
  ///
  /// In en, this message translates to:
  /// **'Language follows your device settings.'**
  String get languageManagedBySystem;

  /// No description provided for @defaultScanQuality.
  ///
  /// In en, this message translates to:
  /// **'Default scan quality'**
  String get defaultScanQuality;

  /// No description provided for @defaultSaveFormat.
  ///
  /// In en, this message translates to:
  /// **'Default save format'**
  String get defaultSaveFormat;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySettings;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect local access to ScanLeno.'**
  String get appLockDescription;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Biometrics'**
  String get biometrics;

  /// No description provided for @biometricsDescription.
  ///
  /// In en, this message translates to:
  /// **'Use device biometrics when available.'**
  String get biometricsDescription;

  /// No description provided for @featureDisabled.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently disabled.'**
  String get featureDisabled;

  /// No description provided for @helpAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Help & Legal'**
  String get helpAndLegal;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @supportLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Support can be connected without uploading your files.'**
  String get supportLocalOnly;

  /// No description provided for @termsSummary.
  ///
  /// In en, this message translates to:
  /// **'Use ScanLeno responsibly and keep your files local unless you choose otherwise.'**
  String get termsSummary;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About ScanLeno'**
  String get aboutApp;

  /// No description provided for @appVersionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0+1'**
  String get appVersionNumber;

  /// No description provided for @localUser.
  ///
  /// In en, this message translates to:
  /// **'Local user'**
  String get localUser;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestMode;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get serverConnectionFailed;

  /// No description provided for @adminBackendHint.
  ///
  /// In en, this message translates to:
  /// **'Start the local backend, then try again.'**
  String get adminBackendHint;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @mostUsedTools.
  ///
  /// In en, this message translates to:
  /// **'Most used tools'**
  String get mostUsedTools;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @ocrPremiumMode.
  ///
  /// In en, this message translates to:
  /// **'OCR as Premium'**
  String get ocrPremiumMode;

  /// No description provided for @advancedPdfTools.
  ///
  /// In en, this message translates to:
  /// **'Advanced PDF tools'**
  String get advancedPdfTools;

  /// No description provided for @watermark.
  ///
  /// In en, this message translates to:
  /// **'Watermark'**
  String get watermark;

  /// No description provided for @freeDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily limit'**
  String get freeDailyLimit;

  /// No description provided for @androidAppId.
  ///
  /// In en, this message translates to:
  /// **'Android App ID'**
  String get androidAppId;

  /// No description provided for @iosAppId.
  ///
  /// In en, this message translates to:
  /// **'iOS App ID'**
  String get iosAppId;

  /// No description provided for @rewardItem.
  ///
  /// In en, this message translates to:
  /// **'Reward item'**
  String get rewardItem;

  /// No description provided for @premiumNoAds.
  ///
  /// In en, this message translates to:
  /// **'Premium users see no ads'**
  String get premiumNoAds;

  /// No description provided for @bannerAds.
  ///
  /// In en, this message translates to:
  /// **'Banner ads'**
  String get bannerAds;

  /// No description provided for @interstitialAds.
  ///
  /// In en, this message translates to:
  /// **'Interstitial ads'**
  String get interstitialAds;

  /// No description provided for @rewardedAds.
  ///
  /// In en, this message translates to:
  /// **'Rewarded ads'**
  String get rewardedAds;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @productId.
  ///
  /// In en, this message translates to:
  /// **'Product ID'**
  String get productId;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get freeTrial;

  /// No description provided for @verifySubscription.
  ///
  /// In en, this message translates to:
  /// **'Verify subscription'**
  String get verifySubscription;

  /// No description provided for @noSupportTickets.
  ///
  /// In en, this message translates to:
  /// **'No support tickets yet.'**
  String get noSupportTickets;

  /// No description provided for @closeTicket.
  ///
  /// In en, this message translates to:
  /// **'Close ticket'**
  String get closeTicket;

  /// No description provided for @createLocalTicket.
  ///
  /// In en, this message translates to:
  /// **'Create local ticket'**
  String get createLocalTicket;

  /// No description provided for @generalMessage.
  ///
  /// In en, this message translates to:
  /// **'General app message'**
  String get generalMessage;

  /// No description provided for @maintenanceAlert.
  ///
  /// In en, this message translates to:
  /// **'Maintenance alert'**
  String get maintenanceAlert;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special offer'**
  String get specialOffer;

  /// No description provided for @privacyNotes.
  ///
  /// In en, this message translates to:
  /// **'Privacy notes'**
  String get privacyNotes;

  /// No description provided for @userFilesUploadPolicy.
  ///
  /// In en, this message translates to:
  /// **'User files upload policy'**
  String get userFilesUploadPolicy;

  /// No description provided for @backendBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get backendBaseUrl;

  /// No description provided for @localTestTicketMessage.
  ///
  /// In en, this message translates to:
  /// **'Local admin test ticket'**
  String get localTestTicketMessage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @extractTextNow.
  ///
  /// In en, this message translates to:
  /// **'Extract text'**
  String get extractTextNow;

  /// No description provided for @scanCreditRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium or one scan credit is required.'**
  String get scanCreditRequired;

  /// No description provided for @ocrPremiumOrCredit.
  ///
  /// In en, this message translates to:
  /// **'Text recognition is available for Premium users or with one rewarded scan credit.'**
  String get ocrPremiumOrCredit;

  /// No description provided for @ocrFailed.
  ///
  /// In en, this message translates to:
  /// **'Text recognition failed. Please try again.'**
  String get ocrFailed;

  /// No description provided for @ocrRateLimited.
  ///
  /// In en, this message translates to:
  /// **'OCR is temporarily rate limited. Please try again later.'**
  String get ocrRateLimited;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @ocrScanCreditAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow OCR with scan_credit'**
  String get ocrScanCreditAccess;

  /// No description provided for @freeDailyOcrLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily OCR limit'**
  String get freeDailyOcrLimit;

  /// No description provided for @premiumMonthlyOcrLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly OCR limit'**
  String get premiumMonthlyOcrLimit;

  /// No description provided for @azureOcrStatus.
  ///
  /// In en, this message translates to:
  /// **'Azure OCR status'**
  String get azureOcrStatus;

  /// No description provided for @freeImageToPdfLimit.
  ///
  /// In en, this message translates to:
  /// **'Free Image to PDF limit'**
  String get freeImageToPdfLimit;

  /// No description provided for @freeFolderLimit.
  ///
  /// In en, this message translates to:
  /// **'Free folder limit'**
  String get freeFolderLimit;

  /// No description provided for @premiumYearlyOcrLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium yearly OCR limit'**
  String get premiumYearlyOcrLimit;

  /// No description provided for @folderLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free folder limit reached.'**
  String get folderLimitReached;

  /// No description provided for @dailyScanLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free daily scan limit reached.'**
  String get dailyScanLimitReached;

  /// No description provided for @imageToPdfLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free Image to PDF limit reached.'**
  String get imageToPdfLimitReached;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device.'**
  String get signOutDescription;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @accountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get accountAccess;

  /// No description provided for @accountOptionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Free users can continue locally. Sign in for Premium, OCR limits, and account management.'**
  String get accountOptionalDescription;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete sign-in. Check your details and try again.'**
  String get authFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get googleSignInCancelled;

  /// No description provided for @googleSignInPopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'The Google sign-in popup was blocked. Allow popups and try again.'**
  String get googleSignInPopupBlocked;

  /// No description provided for @googleSignInUnauthorizedDomain.
  ///
  /// In en, this message translates to:
  /// **'This domain is not allowed for Google sign-in in Firebase.'**
  String get googleSignInUnauthorizedDomain;

  /// No description provided for @googleSignInConfigError.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured correctly for this app.'**
  String get googleSignInConfigError;

  /// No description provided for @googleSignInUiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in cannot open on this device right now.'**
  String get googleSignInUiUnavailable;

  /// No description provided for @googleSignInInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was interrupted. Please try again.'**
  String get googleSignInInterrupted;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Please try again.'**
  String get networkError;

  /// No description provided for @accountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method.'**
  String get accountExistsWithDifferentCredential;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get accountStatus;

  /// No description provided for @registeredUser.
  ///
  /// In en, this message translates to:
  /// **'Registered user'**
  String get registeredUser;

  /// No description provided for @scanCredits.
  ///
  /// In en, this message translates to:
  /// **'Scan credits'**
  String get scanCredits;

  /// No description provided for @localDataFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Showing local device data.'**
  String get localDataFallback;

  /// No description provided for @adminAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Admin access required'**
  String get adminAccessDenied;

  /// No description provided for @adminAccessDeniedDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an admin or owner account to manage ScanLeno settings.'**
  String get adminAccessDeniedDescription;

  /// No description provided for @monthlyOcrUsed.
  ///
  /// In en, this message translates to:
  /// **'Monthly OCR used'**
  String get monthlyOcrUsed;

  /// No description provided for @monthlyOcrLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly OCR limit'**
  String get monthlyOcrLimit;

  /// No description provided for @addScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Add scan credit'**
  String get addScanCredit;

  /// No description provided for @disableUser.
  ///
  /// In en, this message translates to:
  /// **'Disable user'**
  String get disableUser;

  /// No description provided for @enableUser.
  ///
  /// In en, this message translates to:
  /// **'Enable user'**
  String get enableUser;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @watermarkType.
  ///
  /// In en, this message translates to:
  /// **'Watermark type'**
  String get watermarkType;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @logoImage.
  ///
  /// In en, this message translates to:
  /// **'Logo image'**
  String get logoImage;

  /// No description provided for @watermarkText.
  ///
  /// In en, this message translates to:
  /// **'Watermark text'**
  String get watermarkText;

  /// No description provided for @chooseLogo.
  ///
  /// In en, this message translates to:
  /// **'Choose logo'**
  String get chooseLogo;

  /// No description provided for @logoSelected.
  ///
  /// In en, this message translates to:
  /// **'Logo selected'**
  String get logoSelected;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @bottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get bottom;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @repeatOnPage.
  ///
  /// In en, this message translates to:
  /// **'Repeat on page'**
  String get repeatOnPage;

  /// No description provided for @applyToAllPages.
  ///
  /// In en, this message translates to:
  /// **'Apply to all pages'**
  String get applyToAllPages;

  /// No description provided for @saveCopy.
  ///
  /// In en, this message translates to:
  /// **'Save copy'**
  String get saveCopy;

  /// No description provided for @watermarkAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Watermark added successfully.'**
  String get watermarkAddedSuccess;

  /// No description provided for @watermarkAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add watermark. Please try again.'**
  String get watermarkAddFailed;

  /// No description provided for @watermarkDisabled.
  ///
  /// In en, this message translates to:
  /// **'Watermark is disabled from the admin panel.'**
  String get watermarkDisabled;

  /// No description provided for @freeVersionWatermark.
  ///
  /// In en, this message translates to:
  /// **'Free exports include a ScanLeno watermark.'**
  String get freeVersionWatermark;

  /// No description provided for @noWatermarkForPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium users can export without the default watermark.'**
  String get noWatermarkForPremium;

  /// No description provided for @watermarkUnsupportedPdf.
  ///
  /// In en, this message translates to:
  /// **'Existing PDF files cannot be edited directly yet. Use Save & Export to create a watermarked PDF from scanned pages.'**
  String get watermarkUnsupportedPdf;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @noFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No files yet.'**
  String get noFilesYet;

  /// No description provided for @aiTranslate.
  ///
  /// In en, this message translates to:
  /// **'AI Translate'**
  String get aiTranslate;

  /// No description provided for @documentTranslate.
  ///
  /// In en, this message translates to:
  /// **'Document Translate'**
  String get documentTranslate;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @translateSource.
  ///
  /// In en, this message translates to:
  /// **'Text source'**
  String get translateSource;

  /// No description provided for @ocrSavedText.
  ///
  /// In en, this message translates to:
  /// **'Saved OCR text'**
  String get ocrSavedText;

  /// No description provided for @manualText.
  ///
  /// In en, this message translates to:
  /// **'Manual text'**
  String get manualText;

  /// No description provided for @sourceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Source language'**
  String get sourceLanguage;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get targetLanguage;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect'**
  String get autoDetect;

  /// No description provided for @translatedText.
  ///
  /// In en, this message translates to:
  /// **'Translated text'**
  String get translatedText;

  /// No description provided for @translateComplete.
  ///
  /// In en, this message translates to:
  /// **'Translation complete.'**
  String get translateComplete;

  /// No description provided for @translateFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Please try again.'**
  String get translateFailed;

  /// No description provided for @translateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Translation is disabled from the admin panel.'**
  String get translateDisabled;

  /// No description provided for @emptyTranslateText.
  ///
  /// In en, this message translates to:
  /// **'Enter text to translate.'**
  String get emptyTranslateText;

  /// No description provided for @translateTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'The text is too long to translate at once.'**
  String get translateTextTooLong;

  /// No description provided for @unsupportedLanguage.
  ///
  /// In en, this message translates to:
  /// **'This language is not supported yet.'**
  String get unsupportedLanguage;

  /// No description provided for @translateRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Translation is temporarily limited. Please try again later.'**
  String get translateRateLimited;

  /// No description provided for @premiumRequiredForTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translation is available with Premium, or with one scan credit when enabled.'**
  String get premiumRequiredForTranslate;

  /// No description provided for @translateCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'You can use one scan credit for this translation. The credit is only consumed after a successful translation.'**
  String get translateCreditMessage;

  /// No description provided for @watchAdForOneTranslateCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one translate credit'**
  String get watchAdForOneTranslateCredit;

  /// No description provided for @translatePremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Translation Premium only'**
  String get translatePremiumOnly;

  /// No description provided for @translateWithScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Allow translation with scan_credit'**
  String get translateWithScanCredit;

  /// No description provided for @freeDailyTranslateLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily translation limit'**
  String get freeDailyTranslateLimit;

  /// No description provided for @premiumMonthlyTranslateLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly translation limit'**
  String get premiumMonthlyTranslateLimit;

  /// No description provided for @translatorProvider.
  ///
  /// In en, this message translates to:
  /// **'Translator provider'**
  String get translatorProvider;

  /// No description provided for @translatorRegion.
  ///
  /// In en, this message translates to:
  /// **'Translator region'**
  String get translatorRegion;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get copied;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @documentSummary.
  ///
  /// In en, this message translates to:
  /// **'Document Summary'**
  String get documentSummary;

  /// No description provided for @summarySource.
  ///
  /// In en, this message translates to:
  /// **'Summary source'**
  String get summarySource;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @summaryLanguage.
  ///
  /// In en, this message translates to:
  /// **'Summary language'**
  String get summaryLanguage;

  /// No description provided for @summaryLength.
  ///
  /// In en, this message translates to:
  /// **'Summary length'**
  String get summaryLength;

  /// No description provided for @sameAsDocument.
  ///
  /// In en, this message translates to:
  /// **'Same as document'**
  String get sameAsDocument;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @summaryShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get summaryShort;

  /// No description provided for @summaryMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get summaryMedium;

  /// No description provided for @summaryDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get summaryDetailed;

  /// No description provided for @originalText.
  ///
  /// In en, this message translates to:
  /// **'Original text'**
  String get originalText;

  /// No description provided for @summaryText.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryText;

  /// No description provided for @aiSummaryComplete.
  ///
  /// In en, this message translates to:
  /// **'Summary created.'**
  String get aiSummaryComplete;

  /// No description provided for @aiSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not summarize the text. Please try again.'**
  String get aiSummaryFailed;

  /// No description provided for @aiSummaryDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI Summary is disabled from the admin panel.'**
  String get aiSummaryDisabled;

  /// No description provided for @emptySummaryText.
  ///
  /// In en, this message translates to:
  /// **'Enter text to summarize.'**
  String get emptySummaryText;

  /// No description provided for @aiSummaryTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'The text is too long to summarize at once.'**
  String get aiSummaryTextTooLong;

  /// No description provided for @invalidSummaryLength.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid summary length.'**
  String get invalidSummaryLength;

  /// No description provided for @aiSummaryRateLimited.
  ///
  /// In en, this message translates to:
  /// **'AI Summary is temporarily limited. Please try again later.'**
  String get aiSummaryRateLimited;

  /// No description provided for @premiumRequiredForAiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary is available with Premium, or with one scan credit when enabled.'**
  String get premiumRequiredForAiSummary;

  /// No description provided for @aiSummaryCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'You can use one scan credit for this summary. The credit is only consumed after a successful summary.'**
  String get aiSummaryCreditMessage;

  /// No description provided for @watchAdForOneAiSummaryCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one summary credit'**
  String get watchAdForOneAiSummaryCredit;

  /// No description provided for @aiSummaryPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'AI Summary Premium only'**
  String get aiSummaryPremiumOnly;

  /// No description provided for @aiSummaryWithScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Allow AI Summary with scan_credit'**
  String get aiSummaryWithScanCredit;

  /// No description provided for @freeDailySummaryLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily summary limit'**
  String get freeDailySummaryLimit;

  /// No description provided for @premiumMonthlySummaryLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly summary limit'**
  String get premiumMonthlySummaryLimit;

  /// No description provided for @aiSummaryProvider.
  ///
  /// In en, this message translates to:
  /// **'AI Summary provider'**
  String get aiSummaryProvider;

  /// No description provided for @aiSummaryModel.
  ///
  /// In en, this message translates to:
  /// **'AI Summary model'**
  String get aiSummaryModel;

  /// No description provided for @aiSummaryDeployment.
  ///
  /// In en, this message translates to:
  /// **'AI Summary deployment'**
  String get aiSummaryDeployment;

  /// No description provided for @ocrLanguage.
  ///
  /// In en, this message translates to:
  /// **'OCR language'**
  String get ocrLanguage;

  /// No description provided for @ocrDetectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detected language'**
  String get ocrDetectedLanguage;

  /// No description provided for @defaultOcrLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default OCR language'**
  String get defaultOcrLanguage;

  /// No description provided for @allowAutoLanguageDetection.
  ///
  /// In en, this message translates to:
  /// **'Allow auto language detection'**
  String get allowAutoLanguageDetection;

  /// No description provided for @ocrReadModel.
  ///
  /// In en, this message translates to:
  /// **'OCR read model'**
  String get ocrReadModel;

  /// No description provided for @ocrLayoutModel.
  ///
  /// In en, this message translates to:
  /// **'OCR layout model'**
  String get ocrLayoutModel;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @chineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese Simplified'**
  String get chineseSimplified;

  /// No description provided for @chineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Chinese Traditional'**
  String get chineseTraditional;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @malay.
  ///
  /// In en, this message translates to:
  /// **'Malay'**
  String get malay;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @pdfToExcel.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel'**
  String get pdfToExcel;

  /// No description provided for @convertToExcel.
  ///
  /// In en, this message translates to:
  /// **'Convert to Excel'**
  String get convertToExcel;

  /// No description provided for @selectPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Select PDF file'**
  String get selectPdfFile;

  /// No description provided for @noPdfFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No PDF files yet.'**
  String get noPdfFilesYet;

  /// No description provided for @extractAllTables.
  ///
  /// In en, this message translates to:
  /// **'Extract all tables'**
  String get extractAllTables;

  /// No description provided for @oneTablePerSheet.
  ///
  /// In en, this message translates to:
  /// **'One table per sheet'**
  String get oneTablePerSheet;

  /// No description provided for @includeTextSheet.
  ///
  /// In en, this message translates to:
  /// **'Add text sheet'**
  String get includeTextSheet;

  /// No description provided for @pdfToExcelComplete.
  ///
  /// In en, this message translates to:
  /// **'Excel file created.'**
  String get pdfToExcelComplete;

  /// No description provided for @pdfToExcelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not convert this PDF to Excel. Please try again.'**
  String get pdfToExcelFailed;

  /// No description provided for @pdfToExcelDisabled.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel is disabled from the admin panel.'**
  String get pdfToExcelDisabled;

  /// No description provided for @pdfToExcelRateLimited.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel is temporarily limited. Please try again later.'**
  String get pdfToExcelRateLimited;

  /// No description provided for @invalidPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid PDF file.'**
  String get invalidPdfFile;

  /// No description provided for @tablesExtracted.
  ///
  /// In en, this message translates to:
  /// **'Tables extracted'**
  String get tablesExtracted;

  /// No description provided for @pagesProcessed.
  ///
  /// In en, this message translates to:
  /// **'Pages processed'**
  String get pagesProcessed;

  /// No description provided for @excelWorkbook.
  ///
  /// In en, this message translates to:
  /// **'Excel workbook'**
  String get excelWorkbook;

  /// No description provided for @openFileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be opened on this device right now.'**
  String get openFileUnavailable;

  /// No description provided for @premiumRequiredForPdfToExcel.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel is available with Premium, or with one scan credit when enabled.'**
  String get premiumRequiredForPdfToExcel;

  /// No description provided for @pdfToExcelCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'You can use one scan credit for this conversion. The credit is only consumed after a successful Excel file is created.'**
  String get pdfToExcelCreditMessage;

  /// No description provided for @watchAdForOnePdfToExcelCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one Excel conversion credit'**
  String get watchAdForOnePdfToExcelCredit;

  /// No description provided for @pdfToExcelPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel Premium only'**
  String get pdfToExcelPremiumOnly;

  /// No description provided for @pdfToExcelWithScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Allow PDF to Excel with scan_credit'**
  String get pdfToExcelWithScanCredit;

  /// No description provided for @freeDailyPdfToExcelLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily PDF to Excel limit'**
  String get freeDailyPdfToExcelLimit;

  /// No description provided for @premiumMonthlyPdfToExcelLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly PDF to Excel limit'**
  String get premiumMonthlyPdfToExcelLimit;

  /// No description provided for @pdfToExcelProvider.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel provider'**
  String get pdfToExcelProvider;

  /// No description provided for @pdfToExcelModel.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel model'**
  String get pdfToExcelModel;

  /// No description provided for @pdfToWord.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word'**
  String get pdfToWord;

  /// No description provided for @convertToWord.
  ///
  /// In en, this message translates to:
  /// **'Convert to Word'**
  String get convertToWord;

  /// No description provided for @preserveParagraphs.
  ///
  /// In en, this message translates to:
  /// **'Preserve paragraphs'**
  String get preserveParagraphs;

  /// No description provided for @includeTables.
  ///
  /// In en, this message translates to:
  /// **'Include tables'**
  String get includeTables;

  /// No description provided for @includePageBreaks.
  ///
  /// In en, this message translates to:
  /// **'Add page breaks'**
  String get includePageBreaks;

  /// No description provided for @includeHeadings.
  ///
  /// In en, this message translates to:
  /// **'Detect headings'**
  String get includeHeadings;

  /// No description provided for @textDirection.
  ///
  /// In en, this message translates to:
  /// **'Text direction'**
  String get textDirection;

  /// No description provided for @autoTextDirection.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoTextDirection;

  /// No description provided for @rtlDirection.
  ///
  /// In en, this message translates to:
  /// **'Right to left'**
  String get rtlDirection;

  /// No description provided for @ltrDirection.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get ltrDirection;

  /// No description provided for @pdfToWordComplete.
  ///
  /// In en, this message translates to:
  /// **'Word file created.'**
  String get pdfToWordComplete;

  /// No description provided for @pdfToWordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not convert this PDF to Word. Please try again.'**
  String get pdfToWordFailed;

  /// No description provided for @pdfToWordDisabled.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word is disabled from the admin panel.'**
  String get pdfToWordDisabled;

  /// No description provided for @pdfToWordRateLimited.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word is temporarily limited. Please try again later.'**
  String get pdfToWordRateLimited;

  /// No description provided for @pdfToWordInsufficientText.
  ///
  /// In en, this message translates to:
  /// **'Not enough text could be extracted for a Word document.'**
  String get pdfToWordInsufficientText;

  /// No description provided for @paragraphsConverted.
  ///
  /// In en, this message translates to:
  /// **'Paragraphs converted'**
  String get paragraphsConverted;

  /// No description provided for @wordDocument.
  ///
  /// In en, this message translates to:
  /// **'Word document'**
  String get wordDocument;

  /// No description provided for @premiumRequiredForPdfToWord.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word is available with Premium, or with one scan credit when enabled.'**
  String get premiumRequiredForPdfToWord;

  /// No description provided for @pdfToWordCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'You can use one scan credit for this conversion. The credit is only consumed after a successful Word file is created.'**
  String get pdfToWordCreditMessage;

  /// No description provided for @watchAdForOnePdfToWordCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for one Word conversion credit'**
  String get watchAdForOnePdfToWordCredit;

  /// No description provided for @pdfToWordPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word Premium only'**
  String get pdfToWordPremiumOnly;

  /// No description provided for @pdfToWordWithScanCredit.
  ///
  /// In en, this message translates to:
  /// **'Allow PDF to Word with scan_credit'**
  String get pdfToWordWithScanCredit;

  /// No description provided for @freeDailyPdfToWordLimit.
  ///
  /// In en, this message translates to:
  /// **'Free daily PDF to Word limit'**
  String get freeDailyPdfToWordLimit;

  /// No description provided for @premiumMonthlyPdfToWordLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium monthly PDF to Word limit'**
  String get premiumMonthlyPdfToWordLimit;

  /// No description provided for @pdfToWordProvider.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word provider'**
  String get pdfToWordProvider;

  /// No description provided for @pdfToWordModel.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word model'**
  String get pdfToWordModel;
}

class _ScanLenoLocalizationsDelegate
    extends LocalizationsDelegate<ScanLenoLocalizations> {
  const _ScanLenoLocalizationsDelegate();

  @override
  Future<ScanLenoLocalizations> load(Locale locale) {
    return SynchronousFuture<ScanLenoLocalizations>(
      lookupScanLenoLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ScanLenoLocalizationsDelegate old) => false;
}

ScanLenoLocalizations lookupScanLenoLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ScanLenoLocalizationsAr();
    case 'en':
      return ScanLenoLocalizationsEn();
  }

  throw FlutterError(
    'ScanLenoLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

import 'package:flutter/material.dart';

import '../../features/account/presentation/account_page.dart';
import '../../features/account/presentation/auth_page.dart';
import '../../features/admin/presentation/admin_page.dart';
import '../../features/ads/presentation/ads_page.dart';
import '../../features/editor/presentation/editor_page.dart';
import '../../features/export/presentation/export_page.dart';
import '../../features/files/presentation/files_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/ocr/presentation/ocr_page.dart';
import '../../features/premium/presentation/premium_page.dart';
import '../../features/scanner/presentation/capture_page.dart';
import '../../features/scanner/presentation/scanner_page.dart';
import '../../features/signature/presentation/signature_page.dart';
import '../../features/tools/presentation/tools_page.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.home => const HomePage(),
      AppRoutes.files => const FilesPage(),
      AppRoutes.tools => const ToolsPage(),
      AppRoutes.account => const AccountPage(),
      AppRoutes.auth => const AuthPage(),
      AppRoutes.scanner => const CapturePage(),
      AppRoutes.edgeCrop => const ScannerPage(),
      AppRoutes.editor => const EditorPage(),
      AppRoutes.export => const ExportPage(),
      AppRoutes.signature => const SignaturePage(),
      AppRoutes.ocr => const OcrPage(),
      AppRoutes.premium => const PremiumPage(),
      AppRoutes.admin => const AdminPage(),
      AppRoutes.ads => const AdsPage(),
      _ => const HomePage(),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}

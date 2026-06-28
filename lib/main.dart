import 'package:flutter/widgets.dart';

import 'app/scanleno_app.dart';
import 'core/config/scanleno_app_config.dart';
import 'core/constants/feature_flags.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'features/account/application/firebase_auth_service.dart';
import 'features/ads/application/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  scanLenoConfig.validateForStartup();
  await FirebaseBootstrap.initialize();
  await firebaseAuthService.initialize();
  await FeatureFlags.initialize();
  await adService.initialize();

  runApp(const ScanLenoApp());
}

// ignore_for_file: deprecated_member_use, experimental_member_use

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openScanLenoConnection() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb('scanleno.sqlite'),
  );
}

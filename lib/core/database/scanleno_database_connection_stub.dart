import 'package:drift/drift.dart';

QueryExecutor openScanLenoConnection() {
  return LazyDatabase(
    () async => throw UnsupportedError('SQLite is not available here.'),
  );
}

export 'scanleno_database_connection_stub.dart'
    if (dart.library.io) 'scanleno_database_connection_native.dart'
    if (dart.library.js_interop) 'scanleno_database_connection_web.dart';

// Conditional export: export đúng implementation tùy platform
export 'api_config_stub.dart' if (dart.library.io) 'api_config_io.dart';


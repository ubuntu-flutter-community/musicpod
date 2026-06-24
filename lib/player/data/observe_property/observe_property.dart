export 'observe_property_stub.dart'
    if (dart.library.html) 'observe_property_web.dart'
    if (dart.library.io) 'observe_property_io.dart';

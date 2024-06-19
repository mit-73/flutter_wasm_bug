export 'common.dart'
    if (dart.library.html) 'web_legacy.dart'
    if (dart.library.js_interop) 'web.dart'
    if (dart.library.io) 'io.dart' show Picture;

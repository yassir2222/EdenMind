import 'package:flutter/foundation.dart';

// Conditional import to handle web-only library
import 'package:eden_mind_app/core/utils/web_utils_stub.dart'
    if (dart.library.html) 'package:eden_mind_app/core/utils/web_utils_web.dart';

class WebUtils {
  static void registerViewFactory(String viewId, dynamic cb) {
    if (kIsWeb) {
      WebUtilsImpl.registerViewFactory(viewId, cb);
    }
  }
}

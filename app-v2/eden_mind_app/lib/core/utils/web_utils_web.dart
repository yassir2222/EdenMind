import 'dart:ui_web' as ui;

class WebUtilsImpl {
  static void registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}

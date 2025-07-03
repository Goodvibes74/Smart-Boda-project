import 'dart:ui' as ui;

void registerViewFactory(String viewTypeId, ui.ViewFactory factory) {
  ui.platformViewRegistry.registerViewFactory(viewTypeId, factory);
}

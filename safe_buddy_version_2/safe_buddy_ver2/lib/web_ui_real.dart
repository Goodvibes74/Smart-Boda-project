import 'dart:ui' as ui;
import 'dart:html' as html; // Needed for HtmlElement

typedef ViewFactory = html.Element Function(int viewId);

void registerViewFactory(String viewTypeId, ViewFactory factory) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewTypeId, factory);
}

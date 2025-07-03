// File: lib/web_google_map.dart

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class WebGoogleMap extends StatefulWidget {
  const WebGoogleMap({Key? key}) : super(key: key);

  @override
  State<WebGoogleMap> createState() => _WebGoogleMapState();
}

class _WebGoogleMapState extends State<WebGoogleMap> {
  final String viewType = 'map-canvas';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final html.ScriptElement script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyAaZO1HbrM7lyIvLciTF6LxZhWjS_1_3UA'
        ..type = 'text/javascript'
        ..defer = true;

      html.document.body!.append(script);

      script.onLoad.listen((event) {
        final html.ScriptElement mapScript = html.ScriptElement()
          ..innerHtml = '''
            function initMap() {
              var map = new google.maps.Map(document.getElementById("map-canvas"), {
                center: {lat: 0.3476, lng: 32.5825},
                zoom: 12
              });
            }
            google.maps.event.addDomListener(window, 'load', initMap);
          ''';

        html.document.body!.append(mapScript);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'map-canvas');
  }
}

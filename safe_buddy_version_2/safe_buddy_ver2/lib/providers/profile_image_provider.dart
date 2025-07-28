import 'package:flutter/material.dart';

class ProfileImageProvider with ChangeNotifier {
  String? _imageUrl;
  int? _version;

  String? get imageUrl => _version != null ? '$_imageUrl?t=$_version' : _imageUrl;

  void setImageUrl(String url, int version) {
    _imageUrl = url;
    _version = version;
    notifyListeners();
  }
}
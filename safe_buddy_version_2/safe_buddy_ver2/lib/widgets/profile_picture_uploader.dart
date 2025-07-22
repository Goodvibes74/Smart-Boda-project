// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePictureUploader extends StatefulWidget {
  const ProfilePictureUploader({Key? key}) : super(key: key);

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  XFile? _image;
  Uint8List? _webData;
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _photoUrl = user?.photoURL;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) return _showSnack('Image > 5MB');
      setState(() { _image = picked; _webData = bytes; });
    } else {
      final file = File(picked.path);
      if (await file.length() > 5 * 1024 * 1024) return _showSnack('Image > 5MB');
      setState(() => _image = picked);
    }
  }

  Future<void> _confirmBeforeUpload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upload Image?'),
        content: _image != null
            ? (kIsWeb && _webData != null
                ? Image.memory(_webData!)
                : Image.file(File(_image!.path)))
            : const Text('No image selected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upload')),
        ],
      ),
    );
    if (confirmed == true) await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No authenticated user';
      final uid = user.uid;
      final ref = FirebaseStorage.instance.ref('profile_pictures/$uid.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': uid,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (kIsWeb) {
        await ref.putData(_webData!, metadata);
      } else {
        await ref.putFile(File(_image!.path), metadata);
      }

      final url = await ref.getDownloadURL();

      // Update Auth profile
      await user.updatePhotoURL(url);
      await user.reload();

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoURL': url});

      setState(() {
        _photoUrl = url;
        _image = null;
        _webData = null;
      });
      _showSnack('Upload complete');
    } on FirebaseException catch (e) {
      _showSnack('Firebase Error: ${e.message}');
    } catch (e) {
      _showSnack('Unexpected Error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = (BoxConstraints constraints) => constraints.maxWidth < 400 ? 80.0 : 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = size(constraints) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: cs.primaryContainer,
              backgroundImage: _image != null
                  ? (kIsWeb && _webData != null
                      ? MemoryImage(_webData!) as ImageProvider
                      : FileImage(File(_image!.path)))
                  : (_photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null),
              child: (_image == null && _photoUrl == null)
                  ? Icon(Icons.person, size: radius)
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isUploading ? null : _pickImage,
                  child: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Select Image'),
                ),
                if (_image != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _confirmBeforeUpload,
                    child: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Upload'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isUploading
                        ? null
                        : () => setState(() {
                              _image = null;
                              _webData = null;
                            }),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfilePictureUploader extends StatefulWidget {
  const ProfilePictureUploader({super.key});

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  XFile? _image;
  Uint8List? _webImageData;
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null) {
      setState(() => _photoUrl = user.photoURL);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final data = await pickedFile.readAsBytes();
        if (data.length > 5 * 1024 * 1024) {
          _showSnackbar('Image size exceeds 5MB limit');
          return;
        }
        setState(() {
          _image = pickedFile;
          _webImageData = data;
        });
      } else {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _showSnackbar('Image size exceeds 5MB limit');
          return;
        }
        setState(() {
          _image = pickedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('No user signed in');
        return;
      }

      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');

      if (kIsWeb) {
        if (_webImageData != null) {
          await storageRef.putData(_webImageData!);
        } else {
          _showSnackbar('No image data found');
          return;
        }
      } else {
        final file = File(_image!.path);
        await storageRef.putFile(file);
      }

      final downloadUrl = await storageRef.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      setState(() {
        _photoUrl = downloadUrl;
        _image = null;
        _webImageData = null;
      });
      _showSnackbar('Profile picture updated');
    } on FirebaseException catch (e) {
      _showSnackbar('Upload failed: ${e.message}');
    } catch (e) {
      _showSnackbar('Unexpected error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _webImageData = null;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth < 400 ? 80.0 : 100.0;

        Widget imageWidget;
        if (_image != null) {
          if (kIsWeb && _webImageData != null) {
            imageWidget = Image.memory(
              _webImageData!,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.cover,
            );
          } else {
            imageWidget = Image.file(
              File(_image!.path),
              height: imageSize,
              width: imageSize,
              fit: BoxFit.cover,
            );
          }
        } else if (_photoUrl != null) {
          imageWidget = Image.network(
            _photoUrl!,
            height: imageSize,
            width: imageSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
              radius: imageSize / 2,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person, color: cs.onPrimaryContainer, size: imageSize / 2),
            ),
          );
        } else {
          imageWidget = CircleAvatar(
            radius: imageSize / 2,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person, color: cs.onPrimaryContainer, size: imageSize / 2),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary.withOpacity(0.3)),
              ),
              child: ClipOval(child: imageWidget),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _isUploading ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Select Image'),
                ),
                if (_image != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: _isUploading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: cs.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Upload Image'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isUploading ? null : _clearImage,
                    style: TextButton.styleFrom(foregroundColor: cs.primary),
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

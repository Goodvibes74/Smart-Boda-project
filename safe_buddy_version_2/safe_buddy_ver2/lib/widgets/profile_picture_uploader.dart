import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePictureUploader extends StatefulWidget {
  const ProfilePictureUploader({super.key});

  @override
  State<ProfilePictureUploader> createState() =>
      _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  File? _image;
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null) {
      _photoUrl = user.photoURL;
    }

    // 🔄 Listen to auth profile changes
    FirebaseAuth.instance.userChanges().listen((user) {
      if (mounted && user?.photoURL != null) {
        setState(() {
          _photoUrl = user!.photoURL;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile == null) return;

    final file = File(croppedFile.path);
    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size exceeds 5MB limit')),
      );
      return;
    }

    setState(() => _image = file);
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user signed in')),
        );
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user.uid}.jpg');
      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firebase Auth photo
      await user.updatePhotoURL(downloadUrl);

      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'photoURL': downloadUrl}, SetOptions(merge: true));

      setState(() {
        _photoUrl = downloadUrl;
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _clearImage() {
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth < 400 ? 80.0 : 100.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary.withOpacity(0.3)),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(
                        _image!,
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.cover,
                      )
                    : _photoUrl != null
                        ? Image.network(
                            _photoUrl!,
                            height: imageSize,
                            width: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                CircleAvatar(
                              radius: imageSize / 2,
                              backgroundColor: cs.primaryContainer,
                              child: Icon(Icons.person,
                                  color: cs.onPrimaryContainer,
                                  size: imageSize / 2),
                            ),
                          )
                        : CircleAvatar(
                            radius: imageSize / 2,
                            backgroundColor: cs.primaryContainer,
                            child: Icon(Icons.person,
                                color: cs.onPrimaryContainer,
                                size: imageSize / 2),
                          ),
              ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: _isUploading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                color: cs.onPrimary, strokeWidth: 2),
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

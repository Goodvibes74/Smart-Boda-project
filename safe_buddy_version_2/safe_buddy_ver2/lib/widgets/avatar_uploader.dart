import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../providers/profile_image_provider.dart';

final logger = Logger();

class AvatarUploader extends StatelessWidget {
  final double radius;
  final bool allowUpload;
  final VoidCallback? onTap;

  const AvatarUploader({
    Key? key,
    this.radius = 40,
    this.allowUpload = true,
    this.onTap,
  }) : super(key: key);

  Future<void> _uploadImage(BuildContext context) async {
    try {
      // Pick image using image_picker_web
      final bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
        return;
      }

      // Check file size (limit to 5MB)
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must be less than 5MB.')),
        );
        return;
      }

      // Show image preview and confirm upload
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Image'),
          content: Image.memory(bytes, height: 100, fit: BoxFit.contain),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload an image.')),
        );
        return;
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${user.uid}.jpg');
      await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await storageRef.getDownloadURL();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Update Firestore with image URL and version
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'photoURL': downloadUrl,
        'photoVersion': now,
      }).then((_) {
        logger.d('Firestore updated: photoURL=$downloadUrl, photoVersion=$now');
      }).catchError((e) {
        logger.e('Firestore update failed', error: e);
        throw e;
      });

      // Update ProfileImageProvider
      Provider.of<ProfileImageProvider>(context, listen: false)
          .setImageUrl(downloadUrl, now);

      // Clear image cache to ensure new image loads
      imageCache.clear();
      imageCache.clearLiveImages();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      logger.e('Avatar upload failed', error: e);
      String errorMessage;
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'Image picker not available. Please try a different browser.';
      } else if (e is FirebaseException) {
        errorMessage = 'Storage error: ${e.message}';
      } else {
        errorMessage = 'Failed to update avatar: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = context.watch<ProfileImageProvider>().imageUrl;
    logger.d('AvatarUploader build: imageUrl=$imageUrl');
    return GestureDetector(
      onTap: () {
        if (allowUpload) _uploadImage(context);
        if (onTap != null) onTap!();
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Icon(
                Icons.person,
                size: radius,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            : null,
      ),
    );
  }
}
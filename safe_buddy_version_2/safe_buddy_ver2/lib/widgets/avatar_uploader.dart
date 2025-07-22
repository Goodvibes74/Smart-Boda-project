import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_image_provider.dart';

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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      final user = FirebaseAuth.instance.currentUser;

      if (pickedFile != null && user != null) {
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('avatars/${user.uid}.jpg');
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        final now = DateTime.now().millisecondsSinceEpoch;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'photoURL': downloadUrl,
          'photoVersion': now,
        });

        Provider.of<ProfileImageProvider>(context, listen: false)
            .setImageUrl(downloadUrl, now);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = context.watch<ProfileImageProvider>().imageUrl;
    return GestureDetector(
      onTap: () {
        if (allowUpload) _uploadImage(context);
        if (onTap != null) onTap!();
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage:
            imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Icon(Icons.person, size: radius, color: Theme.of(context).colorScheme.onPrimaryContainer)
            : null,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ProfilePictureUploader extends StatefulWidget {
  const ProfilePictureUploader({super.key});

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  File? _image;
  Uint8List? _imageBytes; // For web platform
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null) {
      setState(() => _photoUrl = user.photoURL);
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select Profile Picture',
      );

      if (result != null) {
        if (kIsWeb) {
          // Web platform handling
          if (result.files.single.bytes != null) {
            setState(() {
              _imageBytes = result.files.single.bytes;
              _image = null; // Clear any existing file
            });
          }
        } else {
          // Mobile/Desktop platform handling
          if (result.files.single.path != null) {
            final file = File(result.files.single.path!);
            
            // Check file size (max 5MB)
            final fileSize = await file.length();
            if (fileSize > 5 * 1024 * 1024) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image size exceeds 5MB limit')),
              );
              return;
            }

            setState(() {
              _image = file;
              _imageBytes = null; // Clear any existing bytes
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null && _imageBytes == null) return;
    setState(() => _isUploading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}_$timestamp.jpg');

        // Handle upload differently for web vs other platforms
        if (kIsWeb && _imageBytes != null) {
          await storageRef.putData(_imageBytes!);
        } else if (_image != null) {
          await storageRef.putFile(_image!);
        }

        final downloadUrl = await storageRef.getDownloadURL();
        await user.updatePhotoURL(downloadUrl);
        
        setState(() {
          _photoUrl = downloadUrl;
          _image = null;
          _imageBytes = null;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user signed in')),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageSize = MediaQuery.of(context).size.width < 400 ? 80.0 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary.withOpacity(0.3)),
            ),
            child: ClipOval(
              child: _buildImagePreview(cs, imageSize),
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
            if ((_image != null || _imageBytes != null) && !_isUploading) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                child: const Text('Upload Image'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _clearImage,
                style: TextButton.styleFrom(foregroundColor: cs.primary),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(ColorScheme cs, double imageSize) {
    if (_image != null) {
      return Image.file(
        _image!,
        height: imageSize,
        width: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            _buildDefaultAvatar(cs, imageSize),
      );
    } else if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        height: imageSize,
        width: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            _buildDefaultAvatar(cs, imageSize),
      );
    } else if (_photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: _photoUrl!,
        height: imageSize,
        width: imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: cs.primary,
          ),
        ),
        errorWidget: (context, url, error) => 
            _buildDefaultAvatar(cs, imageSize),
      );
    } else {
      return _buildDefaultAvatar(cs, imageSize);
    }
  }

  Widget _buildDefaultAvatar(ColorScheme cs, double imageSize) {
    return CircleAvatar(
      radius: imageSize / 2,
      backgroundColor: cs.primaryContainer,
      child: Icon(Icons.person, 
          color: cs.onPrimaryContainer, size: imageSize / 2),
    );
  }
}
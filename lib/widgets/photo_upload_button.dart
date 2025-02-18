import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/photo_service.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadButton extends StatelessWidget {
  final String userId;
  final PhotoService _photoService = PhotoService();

  PhotoUploadButton({super.key, required this.userId});

  Future<void> _uploadPhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await _photoService.uploadPhoto(
        locationId: 'current_location',
        imagePath: image.path,
        userId: userId,
        caption: 'Photo taken at this location',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_a_photo),
      color: CinemapsTheme.hotPink,
      onPressed: () => _uploadPhoto(context),
    );
  }
}

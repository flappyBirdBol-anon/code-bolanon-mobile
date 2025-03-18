import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/image_service.dart';
import '../app_colors.dart';

class CustomImageField extends StatelessWidget {
  final XFile? selectedImage;
  final Function(XFile?) onImageSelected;
  final double height;
  final double width;
  final String? imageUrl;
  final String placeholder;
  final bool isCircular;
  final Widget? overlayIcon;
  final ImageService _imageService = locator<ImageService>();

  CustomImageField({
    Key? key,
    this.selectedImage,
    required this.onImageSelected,
    this.height = 180,
    this.width = double.infinity,
    this.imageUrl,
    this.placeholder = 'Add Image',
    this.isCircular = false,
    this.overlayIcon,
    required Widget existingImageWidget,
  }) : super(key: key);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null) {
      onImageSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(isCircular ? height / 2 : 16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        clipBehavior: Clip.antiAlias, // Add this to ensure proper clipping
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) {
      return _buildSelectedImage();
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('assets/')) {
        return _buildAssetImage();
      }
      return _buildCachedImage();
    }
    return _buildPlaceholder();
  }

  Widget _buildSelectedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(selectedImage!.path),
          fit: BoxFit.cover,
        ),
        _buildGradientOverlay(),
        _buildEditIcon(),
      ],
    );
  }

  Widget _buildAssetImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
        _buildGradientOverlay(),
        _buildEditIcon(),
      ],
    );
  }

  Widget _buildCachedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _imageService.loadImage(
          imageUrl: _imageService.getCourseThumbnailFromPath(imageUrl!),
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          ),
          errorWidget: _buildPlaceholder(),
        ),
        _buildGradientOverlay(),
        _buildEditIcon(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCircular)
            Icon(
              Icons.person,
              size: height * 0.5,
              color: Colors.grey[400],
            )
          else
            Icon(
              Icons.image_outlined,
              size: height * 0.3,
              color: Colors.grey[400],
            ),
          if (!isCircular) ...[
            const SizedBox(height: 8),
            Text(
              placeholder,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Click to browse',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5],
        ),
      ),
    );
  }

  Widget _buildEditIcon() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: overlayIcon ??
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 18,
            ),
          ),
    );
  }
}

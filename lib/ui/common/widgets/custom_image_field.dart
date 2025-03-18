import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/image_service.dart';
import '../app_colors.dart';

class CustomImageField extends StatefulWidget {
  final XFile? selectedImage;
  final Function(XFile?) onImageSelected;
  final double height;
  final double width;
  final String? imageUrl;
  final String placeholder;
  final bool isCircular;
  final Widget? overlayIcon;

  const CustomImageField({
    Key? key,
    this.selectedImage,
    required this.onImageSelected,
    this.height = 180,
    this.width = double.infinity,
    this.imageUrl,
    this.placeholder = 'Add Image',
    this.isCircular = false,
    this.overlayIcon,
  }) : super(key: key);

  @override
  State<CustomImageField> createState() => _CustomImageFieldState();
}

class _CustomImageFieldState extends State<CustomImageField> {
  final ImageService _imageService = locator<ImageService>();
  bool _isLoading = false;
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _loadCachedImage();
  }

  @override
  void didUpdateWidget(CustomImageField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadCachedImage();
    }
  }

  Future<void> _loadCachedImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) return;
    if (widget.imageUrl!.startsWith('assets/')) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Try to get the image from cache
      final imageUrl =
          _imageService.getCourseThumbnailFromPath(widget.imageUrl!);
      final file = await _imageService.getCachedImageFile(imageUrl);

      if (file != null) {
        setState(() {
          _cachedFile = file;
        });
      }
    } catch (e) {
      print('Error loading cached image in CustomImageField: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null) {
      widget.onImageSelected(image);
      setState(() {
        _cachedFile = null; // Clear cached file when new image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius:
              BorderRadius.circular(widget.isCircular ? widget.height / 2 : 16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // If a selected image is provided
    if (widget.selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(widget.selectedImage!.path),
            fit: BoxFit.cover,
          ),
          _buildOverlay(),
        ],
      );
    }

    // If we have a cached file
    if (_cachedFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _cachedFile!,
            fit: BoxFit.cover,
          ),
          _buildOverlay(),
        ],
      );
    }

    // If we have an image URL
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (widget.imageUrl!.startsWith('assets/')) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.imageUrl!,
              fit: BoxFit.cover,
            ),
            _buildOverlay(),
          ],
        );
      } else {
        return Stack(
          fit: StackFit.expand,
          children: [
            _imageService.loadImage(
              imageUrl:
                  _imageService.getCourseThumbnailFromPath(widget.imageUrl!),
              width: widget.width,
              height: widget.height,
              placeholder: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : null,
            ),
            _buildOverlay(),
          ],
        );
      }
    }

    // Default placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            widget.placeholder,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: widget.overlayIcon ??
              const Icon(
                Icons.edit,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/custom_image_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CourseCreationView extends StatefulWidget {
  final String? initialCourseName;
  final String? initialDescription;
  final double? initialPrice;
  final Function(String title, String description, double price, XFile? image)
      onSave;
  final bool isEditing;

  const CourseCreationView({
    Key? key,
    this.initialCourseName,
    this.initialDescription,
    this.initialPrice,
    required this.onSave,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<CourseCreationView> createState() => _CourseCreationViewState();
}

class _CourseCreationViewState extends State<CourseCreationView>
    with SingleTickerProviderStateMixin {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  XFile? selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.initialCourseName ?? '');
    descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    priceController =
        TextEditingController(text: widget.initialPrice?.toString() ?? '0');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageHeight =
        screenSize.height * 0.3; // Use screen size for responsive image height

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // This will hide the bottom navigation bar when this page is shown
      resizeToAvoidBottomInset: true,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.isEditing ? 'Edit Course' : 'Create New Course',
          style: GoogleFonts.figtree(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isSubmitting
              ? Container(
                  margin: const EdgeInsets.all(16),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 3,
                  ),
                )
              : TextButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Save',
                    style: GoogleFonts.figtree(),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Course Image Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                          child: CustomImageField(
                            selectedImage: selectedImage,
                            onImageSelected: (image) {
                              setState(() {
                                selectedImage = image;
                              });
                            },
                            height: imageHeight,
                            width: double.infinity,
                            placeholder: 'Add Course Thumbnail',
                            overlayIcon: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(50),
                              color: AppColors.primary,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        selectedImage != null
                                            ? Icons.edit
                                            : Icons.add_photo_alternate,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        selectedImage != null
                                            ? 'Change Image'
                                            : 'Upload Image',
                                        style: GoogleFonts.figtree(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Course Details', Icons.school),
                        const SizedBox(height: 24),

                        // Course Title Field
                        CustomTextField(
                          controller: titleController,
                          labelText: 'Course Title',
                          hintText: 'Enter an engaging title',
                          prefixIcon: Icons.title,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a course title';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Course Description Field
                        CustomTextField(
                          controller: descriptionController,
                          labelText: 'Course Description',
                          hintText: 'What will students learn in this course?',
                          prefixIcon: Icons.description,
                          maxLines: 6, // Increased for better user experience
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Course Price Field
                        CustomTextField(
                          controller: priceController,
                          labelText: 'Course Price',
                          hintText: 'Enter course price',
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          prefix:
                              const Text('\$ ', style: TextStyle(fontSize: 16)),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: _buildSaveButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Saving Course...',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isEditing ? Icons.update : Icons.add_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Update Course' : 'Create Course',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
      maxHeight: 720,
    );
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      widget.onSave(
        titleController.text,
        descriptionController.text,
        double.parse(priceController.text),
        selectedImage,
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

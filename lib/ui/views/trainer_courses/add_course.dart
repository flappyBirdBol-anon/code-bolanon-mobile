import 'dart:io';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/services/tech_stack_service.dart';
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
  final List<String>? initialLearningExpectations;
  final List<String>? initialRequirements;
  final List<String>? initialStacks;
  final String? initialLevel;
  final String? initialDuration;
  final List<int>? initialTechStackIds; // New field for existing tech stack IDs
  final String? initialThumbnail; // Add this field
  final Function(
    String title,
    String description,
    double price,
    XFile? image,
    List<String> learningExpectations,
    List<String> requirements,
    String level,
    String duration,
    List<int> techStackIds, // New parameter to pass tech stack IDs
  ) onSave;
  final bool isEditing;

  const CourseCreationView({
    Key? key,
    this.initialCourseName,
    this.initialDescription,
    this.initialPrice,
    this.initialLearningExpectations,
    this.initialRequirements,
    this.initialStacks,
    this.initialLevel,
    this.initialDuration,
    this.initialTechStackIds, // Initialize this parameter
    this.initialThumbnail, // Add this parameter
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
  late TextEditingController durationController;

  // Controllers for new fields
  final List<TextEditingController> _expectationControllers = [];
  final List<TextEditingController> _requirementControllers = [];

  String _selectedLevel = 'Beginner';
  final List<String> _levelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];

  // Tech stack related fields
  final TechStackService _techStackService = locator<TechStackService>();
  List<TechStackModel> _techStacks = [];
  List<TechStackModel> _selectedTechStacks = [];
  bool _isLoadingTechStacks = true;

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
    durationController =
        TextEditingController(text: widget.initialDuration ?? '');

    // Check if we're in edit mode with an existing thumbnail
    if (widget.isEditing &&
        widget.initialThumbnail != null &&
        widget.initialThumbnail!.isNotEmpty) {
      // The cached image will be loaded by the trainer_courses_viewmodel and passed to onSave
      // We don't need to load it again here since we're displaying with CustomImageField
    }

    // Initialize learning expectations controllers
    if (widget.initialLearningExpectations != null &&
        widget.initialLearningExpectations!.isNotEmpty) {
      for (var item in widget.initialLearningExpectations!) {
        _expectationControllers.add(TextEditingController(text: item));
      }
    } else {
      // Add at least one empty controller
      _expectationControllers.add(TextEditingController());
    }

    // Initialize requirements controllers
    if (widget.initialRequirements != null &&
        widget.initialRequirements!.isNotEmpty) {
      for (var item in widget.initialRequirements!) {
        _requirementControllers.add(TextEditingController(text: item));
      }
    } else {
      // Add at least one empty controller
      _requirementControllers.add(TextEditingController());
    }

    // Set initial level
    if (widget.initialLevel != null) {
      _selectedLevel = widget.initialLevel!;
    }

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

    // Load tech stacks and set selected ones if editing
    _loadTechStacks();
  }

  // Method to load tech stacks from the service
  Future<void> _loadTechStacks() async {
    setState(() {
      _isLoadingTechStacks = true;
    });

    try {
      _techStacks = await _techStackService.fetchTechStacks();

      // If editing a course with existing tech stacks
      if (widget.initialTechStackIds != null &&
          widget.initialTechStackIds!.isNotEmpty) {
        for (var id in widget.initialTechStackIds!) {
          final stack = _techStacks.firstWhere(
            (element) => element.id == id,
            orElse: () => TechStackModel(id: -1, tags: "Unknown"),
          );

          if (stack.id != -1) {
            setState(() {
              _selectedTechStacks.add(stack);
            });
          }
        }
      }
    } catch (e) {
      print('Error loading tech stacks: $e');
    } finally {
      setState(() {
        _isLoadingTechStacks = false;
      });
    }
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
                            imageUrl: widget
                                .initialThumbnail, // Add this line to show initial thumbnail
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

                        // Level and Duration in a Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Level Dropdown
                            Expanded(
                              child: _buildLevelDropdown(),
                            ),
                            const SizedBox(width: 16),
                            // Course Duration Field
                            Expanded(
                              child: CustomTextField(
                                controller: durationController,
                                labelText: 'Course Duration',
                                hintText: 'e.g. 4 weeks, 2 months',
                                prefixIcon: Icons.timer,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter duration';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
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
                              const Text('P ', style: TextStyle(fontSize: 16)),
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

                // Tech Stack Selection Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Tech Stack', Icons.code),
                        const SizedBox(height: 16),
                        _buildTechStackSelection(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Learning Expectations Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                            'Learning Expectations', Icons.lightbulb_outline),
                        const SizedBox(height: 16),
                        _buildDynamicFields(
                          _expectationControllers,
                          'What students will learn',
                          Icons.check_circle_outline,
                          'Learning expectation',
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Requirements Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                            'Course Requirements', Icons.assignment_outlined),
                        const SizedBox(height: 16),
                        _buildDynamicFields(
                          _requirementControllers,
                          'Prerequisites for the course',
                          Icons.list_alt,
                          'Requirement',
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

  // New method to build the tech stack dropdown and chips
  Widget _buildTechStackSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tech Stack Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tech Stack',
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingTechStacks
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(217, 13, 72, 161)),
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Icon(
                          Icons.code,
                          color: Color.fromARGB(226, 13, 72, 161),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TechStackModel>(
                              hint: Text(
                                'Select tech stack',
                                style: GoogleFonts.figtree(
                                  color: Colors.grey[600],
                                ),
                              ),
                              dropdownColor: Colors.white,
                              isDense: true,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              onChanged: (TechStackModel? newValue) {
                                if (newValue != null &&
                                    !_selectedTechStacks.any((element) =>
                                        element.id == newValue.id)) {
                                  setState(() {
                                    _selectedTechStacks.add(newValue);
                                  });
                                }
                              },
                              items: _techStacks
                                  .map<DropdownMenuItem<TechStackModel>>(
                                      (TechStackModel value) {
                                return DropdownMenuItem<TechStackModel>(
                                  value: value,
                                  child: Text(
                                    value.tags,
                                    style: GoogleFonts.figtree(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),

        // Selected Tech Stack Chips
        if (_selectedTechStacks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _selectedTechStacks.map((stack) {
              return Chip(
                avatar: const CircleAvatar(
                  maxRadius: 12,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.code,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                label: Text(stack.tags, style: GoogleFonts.figtree()),
                deleteIcon: const Icon(
                  Icons.cancel,
                  size: 18,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedTechStacks
                        .removeWhere((item) => item.id == stack.id);
                  });
                },
                backgroundColor: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 2),
                labelStyle: GoogleFonts.figtree(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],

        // Validation message if needed
        if (_selectedTechStacks.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Please select at least one tech stack',
            style: GoogleFonts.figtree(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Level',
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.signal_cellular_alt,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLevel,
                    dropdownColor: Colors.white,
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: GoogleFonts.figtree(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLevel = newValue!;
                      });
                    },
                    items: _levelOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.figtree(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFields(
    List<TextEditingController> controllers,
    String hintText,
    IconData icon,
    String label,
  ) {
    return Column(
      children: [
        // Display all the existing fields
        for (int i = 0; i < controllers.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.07),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controllers[i],
                    hintText: '$hintText ${i + 1}',
                    labelText: '$label ${i + 1}',
                    prefixIcon: icon,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    validator: (value) {
                      if (i == 0 && (value?.isEmpty ?? true)) {
                        return 'Please enter at least one item';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    controllers.length > 1
                        ? Icons.remove_circle
                        : Icons.add_circle,
                    color:
                        controllers.length > 1 ? Colors.red : AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      if (controllers.length > 1) {
                        // Remove this field
                        controllers.removeAt(i);
                      } else {
                        // Add a new field if there's only one
                        controllers.add(TextEditingController());
                      }
                    });
                  },
                ),
              ],
            ),
          ),

        // Add button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                controllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add another $label'.toLowerCase(),
              style: GoogleFonts.figtree(),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      ],
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
          style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(189, 0, 0, 0),
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

  // Helper method to extract values from dynamic text field controllers
  List<String> _getTextFieldValues(List<TextEditingController> controllers) {
    return controllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      // Extract learning expectations and requirements
      final learningExpectations = _getTextFieldValues(_expectationControllers);
      final requirements = _getTextFieldValues(_requirementControllers);

      // Extract tech stack IDs
      final techStackIds =
          _selectedTechStacks.map((stack) => stack.id).toList();

      widget.onSave(
        titleController.text,
        descriptionController.text,
        double.parse(priceController.text),
        selectedImage,
        learningExpectations,
        requirements,
        _selectedLevel,
        durationController.text,
        techStackIds, // Pass the tech stack IDs
      );

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();

    // Dispose all dynamic controllers
    for (var controller in _expectationControllers) {
      controller.dispose();
    }
    for (var controller in _requirementControllers) {
      controller.dispose();
    }

    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

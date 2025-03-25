import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'file_viewer.dart';

class LessonContentViewerScreen extends StatelessWidget {
  final Lesson lesson;
  final String? title;
  final String? description;

  const LessonContentViewerScreen({
    Key? key,
    required this.lesson,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: _LessonContentView(
        lesson: lesson,
        title: title,
        description: description,
      ),
    );
  }
}

class _LessonContentView extends StatefulWidget {
  final Lesson lesson;
  final String? title;
  final String? description;

  const _LessonContentView({
    Key? key,
    required this.lesson,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  State<_LessonContentView> createState() => _LessonContentViewState();
}

class _LessonContentViewState extends State<_LessonContentView> {
  final FileService _fileService = locator<FileService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  String _fileUrl = "";

  @override
  void initState() {
    super.initState();
    _fileUrl = _fileService.getLessonFileUrl(widget.lesson);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? widget.lesson.label ?? 'Lesson Content',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (widget.description != null)
            Text(
              widget.description!,
              style: GoogleFonts.figtree(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_fileService.hasFile(widget.lesson)) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildNoContentWidget(),
      );
    }

    final fileType = widget.lesson.fileType ??
        _fileService.getFileType(widget.lesson.fileName!);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FileViewer(
          fileUrl: _fileUrl,
          fileType: fileType,
          title: widget.title ?? widget.lesson.label,
          description: widget.description ?? widget.lesson.description,
          lesson: widget.lesson,
          onError: () {
            _snackbarService.showCustomSnackBar(
              variant: SnackbarType.error,
              message: 'Failed to load content',
              duration: const Duration(seconds: 3),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoContentWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Content Available',
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This lesson does not have any file content to display.',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

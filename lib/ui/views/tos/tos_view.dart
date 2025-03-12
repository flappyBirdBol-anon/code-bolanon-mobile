import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'tos_viewmodel.dart';

class TosView extends StackedView<TosViewModel> {
  const TosView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TosViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Introduction'),
              _buildParagraph(viewModel.introduction),
              const SizedBox(height: 24),
              _buildSectionTitle('2. User Accounts'),
              _buildParagraph(viewModel.userAccounts),
              const SizedBox(height: 24),
              _buildSectionTitle('3. Course Content and Licensing'),
              _buildParagraph(viewModel.courseContent),
              const SizedBox(height: 24),
              _buildSectionTitle('4. Payment Terms'),
              _buildParagraph(viewModel.paymentTerms),
              const SizedBox(height: 24),
              _buildSectionTitle('5. Trainer Obligations'),
              _buildParagraph(viewModel.trainerObligations),
              const SizedBox(height: 24),
              _buildSectionTitle('6. Trainee Rights and Responsibilities'),
              _buildParagraph(viewModel.traineeRights),
              const SizedBox(height: 24),
              _buildSectionTitle('7. Refund Policy'),
              _buildParagraph(viewModel.refundPolicy),
              const SizedBox(height: 24),
              _buildSectionTitle('8. Privacy and Data Protection'),
              _buildParagraph(viewModel.privacyPolicy),
              const SizedBox(height: 24),
              _buildSectionTitle('9. Platform Rules and Code of Conduct'),
              _buildParagraph(viewModel.platformRules),
              const SizedBox(height: 24),
              _buildSectionTitle('10. Contact Information'),
              _buildParagraph(viewModel.contactInfo),
              const SizedBox(height: 32),
              Text(
                'Last updated: ${viewModel.lastUpdated}',
                style: GoogleFonts.figtree(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.figtree(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildParagraph(String content) {
    return Text(
      content,
      style: GoogleFonts.figtree(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey[800],
      ),
    );
  }

  @override
  TosViewModel viewModelBuilder(BuildContext context) => TosViewModel();
}

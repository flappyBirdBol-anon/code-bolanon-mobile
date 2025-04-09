// lib/ui/views/payment/payment_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../models/payment_param.dart';
import 'payment_viewmodel.dart';

class PaymentView extends StackedView<PaymentViewModel> {
  final PaymentParam payment;

  const PaymentView({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PaymentViewModel viewModel,
    Widget? child,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: Text(
          'Payment',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: viewModel.navigateBack,
        ),
      ),
      body: viewModel.isProcessing
          ? _buildLoadingView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildCourseDetails(viewModel),
                    const SizedBox(height: 24),
                    _buildPriceBreakdown(viewModel, currencyFormat),
                    const SizedBox(height: 32),
                    _buildPaymentMethodSelector(viewModel),
                    const SizedBox(height: 24),
                    // Show different forms based on payment method
                    if (viewModel.selectedPaymentMethod == PaymentMethod.stripe)
                      _buildStripeInfoNotice(),
                    const SizedBox(height: 32),
                    _buildPaymentButton(viewModel, context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not close this window',
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetails(PaymentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payment.startAt != null ? 'Appointment Details' : 'Course Details',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.payment?.title ?? '',
            style: GoogleFonts.figtree(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.payment?.description ?? '',
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          if (payment.startAt != null && payment.endAt != null)
            Text(
              '${payment.startAt} - ${payment.endAt}',
              style: GoogleFonts.figtree(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(PaymentViewModel viewModel, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Subtotal', format.format(viewModel.subtotal)),
          if (viewModel.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Discount (${(viewModel.payment?.discountPercentage ?? 0) * 100}%)',
              '- ${format.format(viewModel.discountAmount)}',
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 8),
          _buildPriceRow(
            'Tax (${(viewModel.payment?.taxRate ?? 0) * 100}%)',
            format.format(viewModel.taxAmount),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildPriceRow(
            'Total',
            format.format(viewModel.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF0D47A1) : Colors.grey[800],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.figtree(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isDiscount
                ? Colors.green
                : isTotal
                    ? const Color(0xFF0D47A1)
                    : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(PaymentViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.figtree(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                title: 'Pay with Card',
                subtitle: 'Secure payment via Stripe',
                icon: Icons.credit_card,
                isSelected:
                    viewModel.selectedPaymentMethod == PaymentMethod.stripe,
                onTap: () => viewModel.setPaymentMethod(PaymentMethod.stripe),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPaymentMethodCard(
                title: 'Google Pay',
                subtitle: 'Fast checkout via Google Pay',
                icon: Icons.wallet,
                isSelected:
                    viewModel.selectedPaymentMethod == PaymentMethod.googlePay,
                onTap: () =>
                    viewModel.setPaymentMethod(PaymentMethod.googlePay),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                title: 'In-App Purchase',
                subtitle: 'Via App Store/Play Store',
                icon: Icons.shopping_bag,
                isSelected: viewModel.selectedPaymentMethod ==
                    PaymentMethod.inAppPurchase,
                onTap: () =>
                    viewModel.setPaymentMethod(PaymentMethod.inAppPurchase),
              ),
            ),
            const Expanded(child: SizedBox()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D47A1).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.figtree(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeInfoNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF0D47A1),
              ),
              const SizedBox(width: 8),
              Text(
                'Secure Payment',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'When you click "Pay Now", you will be redirected to Stripe\'s secure payment form to complete your purchase.',
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your payment information is securely processed by Stripe and is never stored on our servers.',
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentButtonText(PaymentViewModel viewModel) {
    switch (viewModel.selectedPaymentMethod) {
      case PaymentMethod.stripe:
        return 'Pay with Card';
      case PaymentMethod.googlePay:
        return 'Pay with Google Pay';
      case PaymentMethod.inAppPurchase:
        return 'Purchase via App Store';
      default:
        return 'Pay Now';
    }
  }

  Widget _buildPaymentButton(PaymentViewModel viewModel, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Call processPayment but don't need to handle the result here
          // as the viewmodel will navigate back with the result
          await viewModel.processPayment();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          _getPaymentButtonText(viewModel),
          style: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  PaymentViewModel viewModelBuilder(BuildContext context) {
    return PaymentViewModel();
  }

  @override
  void onViewModelReady(PaymentViewModel viewModel) {
    viewModel.initialize(payment);
  }
}

// Custom formatters for card input
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

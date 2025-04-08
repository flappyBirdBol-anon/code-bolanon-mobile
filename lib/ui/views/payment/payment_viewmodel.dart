import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/services/payment_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum PaymentMethod { stripe, inAppPurchase, googlePay }

class PaymentViewModel extends BaseViewModel {
  final _paymentService = locator<PaymentService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  PaymentParam? _payment;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.stripe;
  bool _isProcessing = false;
  Transaction? _lastTransaction;

  // Card details
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';

  // Getters
  PaymentParam? get payment => _payment;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;
  Transaction? get lastTransaction => _lastTransaction;

  String get cardNumber => _cardNumber;
  String get expiryDate => _expiryDate;
  String get cvv => _cvv;
  String get cardHolderName => _cardHolderName;

  // Price breakdown calculations
  double get subtotal => _payment?.price ?? 0.0;
  double get discountAmount => subtotal * (_payment?.discountPercentage ?? 0.0);
  double get priceAfterDiscount => subtotal - discountAmount;
  double get taxAmount => priceAfterDiscount * (_payment?.taxRate ?? 0.0);
  double get total => priceAfterDiscount + taxAmount;

  // Initialize with payment
  void initialize(PaymentParam payment) {
    _payment = payment;
    notifyListeners();
  }

  // Set payment method
  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Update card details
  void updateCardNumber(String value) {
    _cardNumber = value;
    notifyListeners();
  }

  void updateExpiryDate(String value) {
    _expiryDate = value;
    notifyListeners();
  }

  void updateCVV(String value) {
    _cvv = value;
    notifyListeners();
  }

  void updateCardHolderName(String value) {
    _cardHolderName = value;
    notifyListeners();
  }

  // Validate card details
  bool _validateCardDetails() {
    // Simple validation for demo purposes
    if (_cardNumber.isEmpty || _cardNumber.replaceAll(' ', '').length < 16) {
      _showErrorDialog(
          'Invalid Card Number', 'Please enter a valid card number.');
      return false;
    }

    if (_expiryDate.isEmpty || !_expiryDate.contains('/')) {
      _showErrorDialog(
          'Invalid Expiry Date', 'Please enter a valid expiry date (MM/YY).');
      return false;
    }

    if (_cvv.isEmpty || _cvv.length < 3) {
      _showErrorDialog('Invalid CVV', 'Please enter a valid security code.');
      return false;
    }

    if (_cardHolderName.isEmpty) {
      _showErrorDialog(
          'Missing Information', 'Please enter the cardholder name.');
      return false;
    }

    return true;
  }

  Future<void> _showErrorDialog(String title, String message) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.error,
      title: title,
      description: message,
    );
  }

  // Process payment
  Future<Map<String, dynamic>> processPayment() async {
    if (_payment == null) {
      return {'success': false, 'message': 'No payment information provided'};
    }

    _isProcessing = true;
    notifyListeners();

    Map<String, dynamic> result;

    try {
      if (_selectedPaymentMethod == PaymentMethod.stripe) {
        // Use Stripe's pre-built UI with Payment Sheet
        result = await _paymentService.processStripePayment(
          payment: _payment!,
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cvv: _cvv,
          cardHolderName: _cardHolderName,
        );
      } else if (_selectedPaymentMethod == PaymentMethod.googlePay) {
        // Use Google Pay through Stripe's Payment Sheet
        result = await _paymentService.processStripePayment(
          payment: _payment!,
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cvv: _cvv,
          cardHolderName: _cardHolderName,
          useGooglePay: true,
        );
      } else {
        // Use native in-app purchase
        result = await _paymentService.processInAppPurchase(
          payment: _payment!,
        );
      }

      if (result['success']) {
        _lastTransaction = result['transaction'] is Map
            ? Transaction.fromJson(result['transaction'])
            : result['transaction'];

        // No success dialog here - just navigate back with result
        _navigationService.back(result: result);
        return result;
      } else {
        await _dialogService.showCustomDialog(
          variant: DialogType.error,
          title: 'Payment Failed',
          description: result['message'] ?? 'An unknown error occurred',
        );
        return result;
      }
    } catch (e) {
      final errorResult = {
        'success': false,
        'message': 'An unexpected error occurred: $e'
      };

      await _dialogService.showCustomDialog(
        variant: DialogType.error,
        title: 'Error',
        description: 'An unexpected error occurred: $e',
      );
      return errorResult;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void navigateBack() {
    _navigationService.back(result: {'success': false, 'cancelled': true});
  }
}

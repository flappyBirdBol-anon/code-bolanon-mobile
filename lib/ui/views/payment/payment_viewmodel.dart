import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_param.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/services/payment_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

enum PaymentMethod { stripe, inAppPurchase, googlePay }

class PaymentViewModel extends BaseViewModel {
  final _paymentService = locator<PaymentService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  CourseParam? _course;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.stripe;
  bool _isProcessing = false;
  Transaction? _lastTransaction;

  // Card details
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';

  // Getters
  CourseParam? get course => _course;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;
  Transaction? get lastTransaction => _lastTransaction;

  String get cardNumber => _cardNumber;
  String get expiryDate => _expiryDate;
  String get cvv => _cvv;
  String get cardHolderName => _cardHolderName;

  // Price breakdown calculations
  double get subtotal => _course?.price ?? 0.0;
  double get discountAmount => subtotal * (_course?.discountPercentage ?? 0.0);
  double get priceAfterDiscount => subtotal - discountAmount;
  double get taxAmount => priceAfterDiscount * (_course?.taxRate ?? 0.0);
  double get total => priceAfterDiscount + taxAmount;

  // Initialize with course
  void initialize(CourseParam course) {
    _course = course;
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
  Future<void> processPayment() async {
    if (_course == null) return;

    _isProcessing = true;
    notifyListeners();

    Map<String, dynamic> result;

    try {
      if (_selectedPaymentMethod == PaymentMethod.stripe) {
        // Use Stripe's pre-built UI with Payment Sheet
        result = await _paymentService.processStripePayment(
          course: _course!,
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cvv: _cvv,
          cardHolderName: _cardHolderName,
        );
      } else if (_selectedPaymentMethod == PaymentMethod.googlePay) {
        // Use Google Pay through Stripe's Payment Sheet
        result = await _paymentService.processStripePayment(
          course: _course!,
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cvv: _cvv,
          cardHolderName: _cardHolderName,
          useGooglePay: true,
        );
      } else {
        // Use native in-app purchase
        result = await _paymentService.processInAppPurchase(
          course: _course!,
        );
      }

      if (result['success']) {
        _lastTransaction = result['transaction'] is Map
            ? Transaction.fromJson(result['transaction'])
            : result['transaction'];

        await _dialogService.showCustomDialog(
          variant: DialogType.success,
          title: 'Payment Successful',
          description:
              'Your payment for ${_course!.title} was successful. Transaction ID: ${_lastTransaction?.id ?? "Unknown"}',
        );

        // Navigate back or to a success screen
        _navigationService.back();
      } else {
        await _dialogService.showCustomDialog(
          variant: DialogType.error,
          title: 'Payment Failed',
          description: result['message'] ?? 'An unknown error occurred',
        );
      }
    } catch (e) {
      await _dialogService.showCustomDialog(
        variant: DialogType.error,
        title: 'Error',
        description: 'An unexpected error occurred: $e',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void navigateBack() {
    _navigationService.back();
  }
}

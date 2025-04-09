import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../models/payment_param.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class PaymentService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Completer to handle in-app purchase results
  Completer<Map<String, dynamic>>? _purchaseCompleter;
  PaymentParam? _currentPayment;

  PaymentService() {
    // Listen to in-app purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onPurchaseDone,
      onError: _onPurchaseError,
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          _purchaseCompleter?.complete({
            'success': false,
            'message': 'Error: ${purchaseDetails.error?.message}',
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase on your backend
          // Then deliver the product
          if (_currentPayment != null) {
            final transaction = Transaction(
              id: purchaseDetails.purchaseID ?? 'unknown',
              paymentId: _currentPayment!.id,
              particulars: _currentPayment!.title,
              amount: _calculateTotalAmount(_currentPayment!),
              paymentMethod: 'In-App Purchase',
              timestamp: DateTime.now(),
              status: 'completed',
              userId: await _getCurrentUserId(), // Fixed: Added user ID
              currency: 'PHP',
              type: _currentPayment?.startAt == null ? 'course' : 'appointment',
            );

            // Save transaction to API
            final result = await _apiService.saveTransaction(transaction);

            if (result['success']) {
              _purchaseCompleter?.complete({
                'success': true,
                'transaction': transaction.toJson(),
                'message': 'Purchase successful',
              });
            } else {
              _purchaseCompleter?.complete({
                'success': false,
                'message': 'Failed to save transaction: ${result['error']}',
              });
            }
          } else {
            _purchaseCompleter?.complete({
              'success': false,
              'message': 'Course information missing',
            });
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _onPurchaseDone() {
    _subscription.cancel();
  }

  void _onPurchaseError(error) {
    _purchaseCompleter?.complete({
      'success': false,
      'message': 'Purchase error: $error',
    });
  }

  // Process Stripe payment using the Payment Sheet (built-in UI)
  Future<Map<String, dynamic>> processStripePayment({
    required PaymentParam payment,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    bool useGooglePay = false,
  }) async {
    try {
      // Create payment intent first
      final paymentIntentResponse = await _apiService.createPaymentIntent(
        amount: (_calculateTotalAmount(payment) * 100).toInt(),
        currency: 'PHP',
        paymentId: payment.id,
        paymentType: payment.startAt == null ? 'course' : 'appointment',
      );

      if (!paymentIntentResponse['success']) {
        return paymentIntentResponse;
      }

      // Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Code Bolanon',
          paymentIntentClientSecret: paymentIntentResponse['clientSecret'],
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF0D47A1),
            ),
          ),
          billingDetails: BillingDetails(name: cardHolderName),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'PH',
            testEnv: true, // Set to false for production
          ),
        ),
      );

      // Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If we get here, the payment was successful
      // Create and save transaction
      final transaction = Transaction(
        id: paymentIntentResponse['id'] ??
            'stripe-${DateTime.now().millisecondsSinceEpoch}',
        paymentId: payment.id,
        particulars: payment.title,
        amount: _calculateTotalAmount(payment),
        paymentMethod: useGooglePay ? 'Google Pay' : 'Stripe',
        timestamp: DateTime.now(),
        status: 'completed',
        userId: await _getCurrentUserId(),
        currency: 'PHP',
        type: _currentPayment?.startAt == null ? 'course' : 'appointment',
      );

      final saveResult = await _apiService.saveTransaction(transaction);

      if (!saveResult['success']) {
        return {
          'success': false,
          'message':
              'Payment successful but failed to save transaction: ${saveResult['error']}',
        };
      }

      // Return the transaction object directly instead of from the API response
      return {
        'success': true,
        'transaction': transaction, // Use the local transaction object
        'message': 'Payment successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment error: $e',
      };
    }
  }

  // Process payment using the manual card entry method
  Future<Map<String, dynamic>> processManualCardPayment({
    required PaymentParam payment,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      // Format expiry date
      final List<String> expiryParts = expiryDate.split('/');
      if (expiryParts.length != 2) {
        return {
          'success': false,
          'message': 'Invalid expiry date format. Please use MM/YY format.',
        };
      }

      final int expiryMonth = int.parse(expiryParts[0]);
      final int expiryYear = int.parse('20${expiryParts[1]}');

      if (expiryMonth < 1 || expiryMonth > 12) {
        return {
          'success': false,
          'message': 'Invalid expiry month. Must be between 1-12.',
        };
      }

      // Create payment intent first
      final paymentIntentResponse = await _apiService.createPaymentIntent(
        amount: (_calculateTotalAmount(payment) * 100).toInt(),
        currency: 'usd',
        paymentId: payment.id,
      );

      if (!paymentIntentResponse['success']) {
        return paymentIntentResponse;
      }

      // Configure card details
      await Stripe.instance.dangerouslyUpdateCardDetails(
        CardDetails(
          number: cardNumber.replaceAll(' ', ''),
          expirationMonth: expiryMonth,
          expirationYear: expiryYear,
          cvc: cvv,
        ),
      );

      // Create payment method
      final paymentMethodParams = PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(name: cardHolderName),
        ),
      );

      // Create payment method and confirm payment
      final paymentMethod = await Stripe.instance
          .createPaymentMethod(params: paymentMethodParams);
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentResponse['clientSecret'],
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: cardHolderName),
          ),
        ),
      );

      // Create and save transaction
      final transaction = Transaction(
        id: paymentIntent.id,
        paymentId: payment.id,
        particulars: payment.title,
        amount: _calculateTotalAmount(payment),
        paymentMethod: 'Stripe',
        timestamp: DateTime.now(),
        status: 'completed',
        userId: await _getCurrentUserId(),
        currency: 'PHP',
        type: _currentPayment?.startAt == null ? 'course' : 'appointment',
      );

      final saveResult = await _apiService.saveTransaction(transaction);

      if (!saveResult['success']) {
        return {
          'success': false,
          'message':
              'Payment successful but failed to save transaction: ${saveResult['error']}',
        };
      }

      return {
        'success': true,
        'transaction': saveResult['transaction'],
        'message': 'Payment successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment error: $e',
      };
    }
  }

  // Process In-App Purchase
  Future<Map<String, dynamic>> processInAppPurchase({
    required PaymentParam payment,
  }) async {
    try {
      // Check if in-app purchases are available
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        return {
          'success': false,
          'message': 'In-app purchases are not available on this device.',
        };
      }

      _currentPayment = payment;
      _purchaseCompleter = Completer<Map<String, dynamic>>();

      // Get product details
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({payment.id});

      if (response.notFoundIDs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Course product not found in store.',
        };
      }

      if (response.error != null) {
        return {
          'success': false,
          'message': 'Error loading product: ${response.error}',
        };
      }

      if (response.productDetails.isEmpty) {
        return {
          'success': false,
          'message': 'No product details found for this payment.',
        };
      }

      final ProductDetails productDetails = response.productDetails.first;

      // Purchase the product
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Start the purchase flow
      final bool purchaseStarted = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!purchaseStarted) {
        return {
          'success': false,
          'message': 'Failed to start purchase process.',
        };
      }

      // Wait for the purchase to complete via purchaseStream listener
      return await _purchaseCompleter!.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => {
          'success': false,
          'message': 'Purchase timed out. Please try again.',
        },
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'In-app purchase error: $e',
      };
    }
  }

  double _calculateTotalAmount(PaymentParam payment) {
    double discountAmount = payment.price * payment.discountPercentage;
    double priceAfterDiscount = payment.price - discountAmount;
    double taxAmount = priceAfterDiscount * payment.taxRate;
    return priceAfterDiscount + taxAmount;
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    return await _apiService.getTransactions();
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    return await _apiService.getTransactionById(id);
  }

  // Clean up resources
  void cleanUp() {
    _subscription.cancel();
  }

  // Helper method to get current user ID
  Future<String> _getCurrentUserId() async {
    // TODO: Implement getting current user ID from your auth service
    return '1'; // Replace with actual implementation
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}

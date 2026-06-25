import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/services/api_service.dart';

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return PaymentNotifier(paymentService, apiService);
});

class PaymentState {
  final bool isLoading;
  final String? error;
  final List<PaymentMethod> paymentMethods;
  final EscrowAccount? escrowAccount;
  final List<Transaction> transactions;
  final Currency selectedCurrency;
  final Map<String, double> exchangeRates;

  const PaymentState({
    this.isLoading = false,
    this.error,
    this.paymentMethods = const [],
    this.escrowAccount,
    this.transactions = const [],
    this.selectedCurrency = Currency.USD,
    this.exchangeRates = const {},
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    List<PaymentMethod>? paymentMethods,
    EscrowAccount? escrowAccount,
    List<Transaction>? transactions,
    Currency? selectedCurrency,
    Map<String, double>? exchangeRates,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      escrowAccount: escrowAccount ?? this.escrowAccount,
      transactions: transactions ?? this.transactions,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _paymentService;
  final ApiService _apiService;

  PaymentNotifier(this._paymentService, this._apiService) : super(const PaymentState()) {
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      await _paymentService.initializeStripe();
      await loadExchangeRates();
      await loadPaymentData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadExchangeRates() async {
    try {
      final rates = await _paymentService.getExchangeRates();
      state = state.copyWith(exchangeRates: rates);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load exchange rates');
    }
  }

  Future<void> loadPaymentData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get current user
      final user = _apiService.token != null ? await _getCurrentUser() : null;
      if (user == null) return;

      // Load payment methods
      final paymentMethods = await _paymentService.getPaymentMethods(user['id']);
      
      // Load escrow account
      final escrowAccount = await _paymentService.getEscrowAccount(user['id']);
      
      // Load transactions
      final transactions = await _paymentService.getTransactionHistory(user['id']);

      state = state.copyWith(
        isLoading: false,
        paymentMethods: paymentMethods,
        escrowAccount: escrowAccount,
        transactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load payment data',
      );
    }
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    try {
      final response = await _apiService.getMe();
      return response.data;
    } catch (e) {
      return null;
    }
  }

  void setSelectedCurrency(Currency currency) {
    state = state.copyWith(selectedCurrency: currency);
  }

  Future<PaymentIntent?> createPaymentIntent({
    required double amount,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final paymentIntent = await _paymentService.createPaymentIntent(
        amount: amount,
        currency: state.selectedCurrency,
        description: description,
      );

      state = state.copyWith(isLoading: false);
      return paymentIntent;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create payment intent',
      );
      return null;
    }
  }

  Future<PaymentMethod?> addPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardholderName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final paymentMethod = await _paymentService.createPaymentMethod(
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
        cardholderName: cardholderName,
      );

      final updatedMethods = [...state.paymentMethods, paymentMethod];
      state = state.copyWith(
        isLoading: false,
        paymentMethods: updatedMethods,
      );
      
      return paymentMethod;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add payment method',
      );
      return null;
    }
  }

  Future<bool> makePayment({
    required double amount,
    required String description,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Create payment intent
      final paymentIntent = await _paymentService.createPaymentIntent(
        amount: amount,
        currency: state.selectedCurrency,
        description: description,
      );

      // Confirm payment
      if (paymentMethod != null) {
        await _paymentService.confirmPayment(
          paymentIntentId: paymentIntent.id,
          paymentMethodId: paymentMethod.id,
        );
      }

      // Add to escrow if needed
      final user = await _getCurrentUser();
      if (user != null) {
        await _paymentService.addToEscrow(
          userId: user['id'],
          amount: amount,
          currency: state.selectedCurrency,
          transactionId: paymentIntent.id,
        );
      }

      // Reload payment data
      await loadPaymentData();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Payment failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<EscrowAccount?> createEscrowAccount() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      final escrowAccount = await _paymentService.createEscrowAccount(
        userId: user['id'],
        currency: state.selectedCurrency,
      );

      state = state.copyWith(
        isLoading: false,
        escrowAccount: escrowAccount,
      );
      
      return escrowAccount;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create escrow account',
      );
      return null;
    }
  }

  Future<bool> releaseEscrowFunds({
    required double amount,
    required String recipientId,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      await _paymentService.releaseFromEscrow(
        userId: user['id'],
        amount: amount,
        recipientId: recipientId,
        description: description,
      );

      await loadPaymentData();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to release escrow funds',
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> generateInvoice({
    required String transactionId,
    required Map<String, dynamic> projectDetails,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      final invoice = await _paymentService.generateInvoice(
        transactionId: transactionId,
        customerId: user['id'],
        projectDetails: projectDetails,
      );

      state = state.copyWith(isLoading: false);
      return invoice;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate invoice',
      );
      return null;
    }
  }

  Future<double> convertCurrencyAmount({
    required double amount,
    required Currency from,
    required Currency to,
  }) async {
    try {
      return await _paymentService.convertCurrency(amount, from, to);
    } catch (e) {
      return amount; // Return original amount if conversion fails
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

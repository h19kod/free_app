import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// Supported currencies
enum Currency {
  USD('usd', '\$', 'United States Dollar'),
  EUR('eur', '€', 'Euro'),
  SAR('sar', '﷼', 'Saudi Riyal'),
  AED('aed', 'د.إ', 'UAE Dirham'),
  GBP('gbp', '£', 'British Pound'),
  JPY('jpy', '¥', 'Japanese Yen'),
  CNY('cny', '¥', 'Chinese Yuan'),
  INR('inr', '₹', 'Indian Rupee');

  const Currency(this.code, this.symbol, this.name);
  final String code;
  final String symbol;
  final String name;
}

// Payment models
class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String brand;
  final DateTime expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      last4: json['last4'],
      brand: json['brand'],
      expiryDate: DateTime.parse(json['expiry_date']),
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expiry_date': expiryDate.toIso8601String(),
      'is_default': isDefault,
    };
  }
}

class Transaction {
  final String id;
  final double amount;
  final Currency currency;
  final String status;
  final String description;
  final DateTime createdAt;
  final PaymentMethod? paymentMethod;
  final String? stripePaymentIntentId;

  Transaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
    this.paymentMethod,
    this.stripePaymentIntentId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      currency: Currency.values.firstWhere((c) => c.code == json['currency']),
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      paymentMethod: json['payment_method'] != null 
          ? PaymentMethod.fromJson(json['payment_method']) 
          : null,
      stripePaymentIntentId: json['stripe_payment_intent_id'],
    );
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

class EscrowAccount {
  final String id;
  final double balance;
  final Currency currency;
  final List<Transaction> transactions;
  final bool isVerified;

  EscrowAccount({
    required this.id,
    required this.balance,
    required this.currency,
    required this.transactions,
    this.isVerified = false,
  });

  factory EscrowAccount.fromJson(Map<String, dynamic> json) {
    return EscrowAccount(
      id: json['id'],
      balance: json['balance'].toDouble(),
      currency: Currency.values.firstWhere((c) => c.code == json['currency']),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      isVerified: json['is_verified'] ?? false,
    );
  }

  String get formattedBalance {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 2,
    );
    return formatter.format(balance);
  }
}

// Payment service
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

class PaymentService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Test mode - replace with your actual Stripe keys
  static const String _testPublishableKey = 'pk_test_51234567890abcdef';
  static const String _testSecretKey = 'sk_test_51234567890abcdef';
  static const String _testAccountId = 'acct_test_1234567890';

  PaymentService() {
    _dio.options.baseUrl = 'https://api.stripe.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $_testSecretKey';
    _dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
  }

  // Initialize Stripe
  Future<void> initializeStripe() async {
    try {
      Stripe.publishableKey = _testPublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      throw Exception('Failed to initialize Stripe: $e');
    }
  }

  // Get exchange rates (mock implementation)
  Future<Map<String, double>> getExchangeRates() async {
    // Mock exchange rates - in real app, fetch from API
    return {
      'USD': 1.0,
      'EUR': 0.85,
      'SAR': 3.75,
      'AED': 3.67,
      'GBP': 0.73,
      'JPY': 110.0,
      'CNY': 6.45,
      'INR': 74.0,
    };
  }

  // Convert currency
  Future<double> convertCurrency(
    double amount,
    Currency from,
    Currency to,
  ) async {
    if (from == to) return amount;
    
    final rates = await getExchangeRates();
    final usdAmount = amount / rates[from.code];
    return usdAmount * rates[to.code];
  }

  // Create payment intent
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required Currency currency,
    required String description,
    String? customerId,
  }) async {
    try {
      final response = await _dio.post(
        '/payment_intents',
        data: {
          'amount': (amount * 100).round(), // Stripe uses cents
          'currency': currency.code,
          'description': description,
          'customer': customerId,
          'payment_method_types': ['card'],
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      return PaymentIntent.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Confirm payment
  Future<PaymentIntent> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _dio.post(
        '/payment_intents/$paymentIntentId/confirm',
        data: {
          'payment_method': paymentMethodId,
        },
      );

      return PaymentIntent.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  // Create payment method
  Future<PaymentMethod> createPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardholderName,
  }) async {
    try {
      // Create card token
      final cardToken = await Stripe.instance.createToken(
        CardDetails(
          number: cardNumber,
          expirationMonth: int.parse(expiryMonth),
          expirationYear: int.parse(expiryYear),
          cvc: cvc,
        ),
      );

      // Create payment method
      final response = await _dio.post(
        '/payment_methods',
        data: {
          'type': 'card',
          'card[token]': cardToken.id,
          'billing_details[name]': cardholderName,
        },
      );

      return PaymentMethod.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create payment method: $e');
    }
  }

  // Get saved payment methods
  Future<List<PaymentMethod>> getPaymentMethods(String customerId) async {
    try {
      final response = await _dio.get(
        '/payment_methods',
        queryParameters: {
          'customer': customerId,
          'type': 'card',
        },
      );

      return (response.data['data'] as List)
          .map((pm) => PaymentMethod.fromJson(pm))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  // Create escrow account
  Future<EscrowAccount> createEscrowAccount({
    required String userId,
    required Currency currency,
  }) async {
    try {
      // Mock implementation - in real app, create with Stripe Connect
      final mockAccount = EscrowAccount(
        id: 'escrow_${DateTime.now().millisecondsSinceEpoch}',
        balance: 0.0,
        currency: currency,
        transactions: [],
        isVerified: false,
      );

      await _storage.write(
        key: 'escrow_account_$userId',
        value: jsonEncode(mockAccount.toJson()),
      );

      return mockAccount;
    } catch (e) {
      throw Exception('Failed to create escrow account: $e');
    }
  }

  // Get escrow account
  Future<EscrowAccount?> getEscrowAccount(String userId) async {
    try {
      final data = await _storage.read(key: 'escrow_account_$userId');
      if (data == null) return null;

      return EscrowAccount.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  // Add funds to escrow
  Future<void> addToEscrow({
    required String userId,
    required double amount,
    required Currency currency,
    required String transactionId,
  }) async {
    try {
      final account = await getEscrowAccount(userId);
      if (account == null) {
        throw Exception('Escrow account not found');
      }

      final transaction = Transaction(
        id: transactionId,
        amount: amount,
        currency: currency,
        status: 'completed',
        description: 'Funds added to escrow',
        createdAt: DateTime.now(),
      );

      account.transactions.add(transaction);
      account.balance += amount;

      await _storage.write(
        key: 'escrow_account_$userId',
        value: jsonEncode(account.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to add funds to escrow: $e');
    }
  }

  // Release funds from escrow
  Future<void> releaseFromEscrow({
    required String userId,
    required double amount,
    required String recipientId,
    required String description,
  }) async {
    try {
      final account = await getEscrowAccount(userId);
      if (account == null) {
        throw Exception('Escrow account not found');
      }

      if (account.balance < amount) {
        throw Exception('Insufficient escrow balance');
      }

      final transaction = Transaction(
        id: 'release_${DateTime.now().millisecondsSinceEpoch}',
        amount: -amount,
        currency: account.currency,
        status: 'completed',
        description: description,
        createdAt: DateTime.now(),
      );

      account.transactions.add(transaction);
      account.balance -= amount;

      await _storage.write(
        key: 'escrow_account_$userId',
        value: jsonEncode(account.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to release funds from escrow: $e');
    }
  }

  // Get transaction history
  Future<List<Transaction>> getTransactionHistory(String userId) async {
    try {
      final account = await getEscrowAccount(userId);
      return account?.transactions ?? [];
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // Generate invoice
  Future<Map<String, dynamic>> generateInvoice({
    required String transactionId,
    required String customerId,
    required Map<String, dynamic> projectDetails,
  }) async {
    try {
      final invoice = {
        'id': 'inv_${DateTime.now().millisecondsSinceEpoch}',
        'transaction_id': transactionId,
        'customer_id': customerId,
        'project_details': projectDetails,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
        'due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };

      return invoice;
    } catch (e) {
      throw Exception('Failed to generate invoice: $e');
    }
  }
}

extension EscrowAccountExtension on EscrowAccount {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'currency': currency.code,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'is_verified': isVerified,
    };
  }
}

extension TransactionExtension on Transaction {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency.code,
      'status': status,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'payment_method': paymentMethod?.toJson(),
      'stripe_payment_intent_id': stripePaymentIntentId,
    };
  }
}

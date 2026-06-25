import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final paymentNotifier = ref.read(paymentProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Payment', icon: Icon(Icons.payment)),
            Tab(text: 'Wallet', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          PopupMenuButton<Currency>(
            icon: Text(paymentState.selectedCurrency.symbol),
            onSelected: (currency) {
              paymentNotifier.setSelectedCurrency(currency);
            },
            itemBuilder: (context) {
              return Currency.values.map((currency) {
                return PopupMenuItem(
                  value: currency,
                  child: Row(
                    children: [
                      Text(currency.symbol),
                      const SizedBox(width: 8),
                      Text(currency.name),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentTab(paymentState, paymentNotifier),
          _buildWalletTab(paymentState, paymentNotifier),
          _buildHistoryTab(paymentState),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(PaymentState state, PaymentNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error display
          if (state.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => notifier.clearError(),
                  ),
                ],
              ),
            ),
          ],

          // Quick payment section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (state.paymentMethods.isNotEmpty) ...[
                          const Text('Select Payment Method:'),
                          const SizedBox(height: 8),
                          ...state.paymentMethods.map((method) {
                            return RadioListTile<PaymentMethod>(
                              title: Text('${method.brand} •••• ${method.last4}'),
                              subtitle: Text('Expires ${method.expiryDate.month}/${method.expiryDate.year}'),
                              value: method,
                              groupValue: null,
                              onChanged: (value) {},
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                final amount = double.parse(_amountController.text);
                                final success = await notifier.makePayment(
                                  amount: amount,
                                  description: _descriptionController.text,
                                );
                                
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment successful!')),
                                  );
                                  _clearForm();
                                }
                              }
                            },
                            child: state.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Pay Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add new payment method
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: const InputDecoration(
                            labelText: 'MM/YY',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvcController,
                          decoration: const InputDecoration(
                            labelText: 'CVC',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardholderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : () async {
                        if (_cardNumberController.text.length == 16 &&
                            _expiryController.text.isNotEmpty &&
                            _cvcController.text.isNotEmpty &&
                            _cardholderNameController.text.isNotEmpty) {
                          
                          final parts = _expiryController.text.split('/');
                          if (parts.length == 2) {
                            final paymentMethod = await notifier.addPaymentMethod(
                              cardNumber: _cardNumberController.text,
                              expiryMonth: parts[0],
                              expiryYear: parts[1],
                              cvc: _cvcController.text,
                              cardholderName: _cardholderNameController.text,
                            );
                            
                            if (paymentMethod != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Payment method added!')),
                              );
                              _clearCardForm();
                            }
                          }
                        }
                      },
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Card'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTab(PaymentState state, PaymentNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Escrow Account
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Escrow Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (state.escrowAccount?.isVerified == true)
                        const Icon(Icons.verified, color: AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.escrowAccount != null) ...[
                    Text(
                      'Balance: ${state.escrowAccount!.formattedBalance}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Currency: ${state.escrowAccount!.currency.name}',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ] else ...[
                    const Text('No escrow account'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final account = await notifier.createEscrowAccount();
                          if (account != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Escrow account created!')),
                            );
                          }
                        },
                        child: const Text('Create Escrow Account'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment Methods
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (state.paymentMethods.isEmpty) ...[
                    const Text('No payment methods added'),
                  ] else ...[
                    ...state.paymentMethods.map((method) {
                      return ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text('${method.brand} •••• ${method.last4}'),
                        subtitle: Text('Expires ${method.expiryDate.month}/${method.expiryDate.year}'),
                        trailing: method.isDefault
                            ? const Icon(Icons.star, color: AppTheme.warning)
                            : null,
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Currency Exchange
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exchange Rates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (state.exchangeRates.isEmpty) ...[
                    const Text('Loading exchange rates...'),
                  ] else ...[
                    ...state.exchangeRates.entries.map((entry) {
                      final currency = Currency.values.firstWhere((c) => c.code == entry.key);
                      return ListTile(
                        title: Text(currency.name),
                        subtitle: Text('1 USD = ${entry.value.toStringAsFixed(2)} ${currency.code}'),
                        trailing: Text(currency.symbol),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(PaymentState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.transactions.isEmpty) ...[
            const Center(
              child: Text('No transactions yet'),
            ),
          ] else ...[
            ...state.transactions.map((transaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    transaction.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: transaction.amount > 0 ? AppTheme.success : AppTheme.error,
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(transaction.createdAt.toString().split('.')[0]),
                  trailing: Text(
                    transaction.formattedAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.amount > 0 ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
  }

  void _clearCardForm() {
    _cardNumberController.clear();
    _expiryController.clear();
    _cvcController.clear();
    _cardholderNameController.clear();
  }
}

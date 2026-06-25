import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_components.dart';
import '../../../core/widgets/animated_widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Analytics & Insights',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ).animateWithSlide(),
              
              const SizedBox(height: 24),
              
              // Stats Grid
              CustomStatsGrid(
                items: [
                  CustomStatItem(
                    title: 'Total Earnings',
                    value: '\$15,420',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    change: '+12%',
                    isPositiveChange: true,
                  ),
                  CustomStatItem(
                    title: 'Active Projects',
                    value: '8',
                    icon: Icons.work,
                    color: Colors.blue,
                    change: '+2',
                    isPositiveChange: true,
                  ),
                  CustomStatItem(
                    title: 'Total Reviews',
                    value: '47',
                    icon: Icons.star,
                    color: Colors.amber,
                    change: '+5',
                    isPositiveChange: true,
                  ),
                  CustomStatItem(
                    title: 'Response Rate',
                    value: '95%',
                    icon: Icons.speed,
                    color: Colors.purple,
                    change: '+3%',
                    isPositiveChange: true,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Revenue Chart
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenue Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Chart Placeholder'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(3, (index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            index == 0 ? Icons.message : 
                            index == 1 ? Icons.payment : Icons.star,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(index == 0 ? 'New message received' : 
                                   index == 1 ? 'Payment received' : 
                                   'New review posted'),
                        subtitle: Text('${index + 1} hour${index > 0 ? 's' : ''} ago'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

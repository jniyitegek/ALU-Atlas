import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/venture_logo.dart';
import '../../../startup/presentation/controllers/startup_provider.dart';
import '../controllers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _updating = false;

  Future<void> _toggleVerification(String startupId, bool currentStatus) async {
    setState(() => _updating = true);
    try {
      final newStatus = !currentStatus;
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update startup document
      final startupDoc = FirebaseFirestore.instance.collection('startups').doc(startupId);
      batch.update(startupDoc, {'isVerified': newStatus});

      // 2. Update user (owner) document
      final userDoc = FirebaseFirestore.instance.collection('users').doc(startupId);
      batch.update(userDoc, {'isStartupVerified': newStatus});

      // 3. Update all child opportunities owned by this startup
      final oppsQuery = await FirebaseFirestore.instance
          .collection('opportunities')
          .where('startupId', isEqualTo: startupId)
          .get();

      for (final doc in oppsQuery.docs) {
        batch.update(doc.reference, {'isStartupVerified': newStatus});
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Venture verification ${newStatus ? "activated" : "revoked"}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupsAsync = ref.watch(startupsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Campus Ventures Verification Control',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Verify student-led startups to grant them the verified badge across the ALU Atlas platform.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: startupsAsync.when(
                data: (startups) {
                  if (startups.isEmpty) {
                    return const Center(child: Text('No startups found in the database.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: startups.length,
                    itemBuilder: (context, index) {
                      final startup = startups[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            VentureLogo(
                              logoUrl: startup.logoUrl,
                              name: startup.name,
                              size: 48,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          startup.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                                        ),
                                      ),
                                      if (startup.isVerified)
                                        const Icon(Icons.verified, color: AppColors.primary, size: 16),
                                    ],
                                  ),
                                  if (startup.domain.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(startup.domain, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  ],
                                  if (startup.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      startup.description,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: startup.isVerified,
                              onChanged: _updating ? null : (_) => _toggleVerification(startup.id, startup.isVerified),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

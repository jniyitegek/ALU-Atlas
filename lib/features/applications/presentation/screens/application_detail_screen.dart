import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/application_entity.dart';
import '../controllers/applications_provider.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class ApplicationDetailScreen extends ConsumerWidget {
  final ApplicationEntity application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the applications stream to get real-time state updates
    final appsStream = ref.watch(applicationsStreamProvider);
    
    // Find the latest state of this application from the stream
    final currentApp = appsStream.maybeWhen(
      data: (list) => list.firstWhere((a) => a.id == application.id, orElse: () => application),
      orElse: () => application,
    );

    final currentStatus = currentApp.status;
    
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;
    final isVentureOwner = currentUser?.role == 'startup_owner';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Applications cannot be deleted after review.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Delivery Details equivalent block (Application Progress Dashboard)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Application Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Horizontal progress bar (matching Placed -> Accepted -> Preparing -> Dispatched -> Delivered style)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _progressStep(
                          icon: Icons.assignment_turned_in,
                          label: 'Applied',
                          isActive: _isStageActive('applied', currentStatus),
                        ),
                        _progressLine(_isStageActive('under_review', currentStatus)),
                        _progressStep(
                          icon: Icons.rate_review,
                          label: 'Reviewed',
                          isActive: _isStageActive('under_review', currentStatus),
                        ),
                        _progressLine(_isStageActive('shortlisted', currentStatus)),
                        _progressStep(
                          icon: Icons.checklist,
                          label: 'Shortlist',
                          isActive: _isStageActive('shortlisted', currentStatus),
                        ),
                        _progressLine(_isStageActive('offered', currentStatus)),
                        _progressStep(
                          icon: Icons.card_giftcard,
                          label: 'Offered',
                          isActive: _isStageActive('offered', currentStatus),
                        ),
                        _progressLine(_isStageActive('hired', currentStatus)),
                        _progressStep(
                          icon: Icons.verified_user,
                          label: 'Hired',
                          isActive: _isStageActive('hired', currentStatus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons matching Screen 2 "Track Order" & "Feedback"
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/application-tracking', extra: currentApp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, // Royal Blue
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Track Updates',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.push('/inbox', extra: currentApp);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Feedback/Chat',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail Location Block (Venture Name & Student Details)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Store Name row
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.business, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Venture Name',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                             Text(
                               currentApp.startupName,
                               style: const TextStyle(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.text,
                               ),
                             ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Student Location/Contact Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Applicant Profile Details',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _detailRow('Full Name', currentApp.studentName),
                              _detailRow('Email Address', currentApp.studentEmail),
                              _detailRow('Target Position', currentApp.opportunityTitle),
                              _detailRow('Ecosystem Cohort', 'ALU Kigali 2026'),
                              if (currentApp.candidateAge != null)
                                _detailRow('Age Eligibility', '${currentApp.candidateAge} Years old'),
                              if (currentApp.candidateExperienceYears != null)
                                _detailRow('Experience', '${currentApp.candidateExperienceYears} Years'),
                              if (currentApp.candidateResumeName != null)
                                _detailRow('Attached CV', currentApp.candidateResumeName!),
                              if (currentApp.candidatePortfolioUrl != null)
                                _detailRow('Portfolio / Github', currentApp.candidatePortfolioUrl!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Details Block (Stipend details)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stipend & Compensation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Base Monthly Stipend',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        Text(
                          currentApp.stipend,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Payment Processing Method',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        Text(
                          'ALU Wallet / MoMo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isVentureOwner) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.gavel_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Application Management',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Conclude assessments, coordinate interviews, or extend formal placement offers.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _managementButton(ref, currentApp.id, 'under_review', 'Review Profile', 'Hiring manager opened application files.'),
                          _managementButton(ref, currentApp.id, 'shortlisted', 'Shortlist', 'Candidate matches basic skill indices.'),
                          _managementButton(ref, currentApp.id, 'interview_scheduled', 'Schedule Interview', 'Interview scheduled with candidate.'),
                          _managementButton(ref, currentApp.id, 'offered', 'Extend Offer', 'Stipend details & onboarding packet sent.'),
                          _managementButton(ref, currentApp.id, 'hired', 'Hire Candidate', 'Placement offer accepted. Hired!'),
                          _managementButton(ref, currentApp.id, 'rejected', 'Decline Application', 'Role has been filled by another applicant.'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isStageActive(String stage, String currentStatus) {
    const order = ['applied', 'under_review', 'shortlisted', 'interview_scheduled', 'offered', 'hired'];
    final currentIndex = order.indexOf(currentStatus);
    final stageIndex = order.indexOf(stage);
    
    if (currentStatus == 'rejected') {
      return stage == 'applied'; // only applied is active if rejected
    }
    
    return stageIndex <= currentIndex;
  }

  Widget _progressStep({required IconData icon, required String label, required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.text : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _progressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? AppColors.accent : Colors.grey.shade300,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _managementButton(WidgetRef ref, String appId, String status, String label, String comment) {
    final isDecline = status == 'rejected';
    return ElevatedButton(
      onPressed: () {
        ref.read(applicationsControllerProvider).updateStatus(appId, status, comment, 'owner1');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDecline ? Colors.red.shade50 : AppColors.primary.withOpacity(0.08),
        foregroundColor: isDecline ? Colors.red : AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

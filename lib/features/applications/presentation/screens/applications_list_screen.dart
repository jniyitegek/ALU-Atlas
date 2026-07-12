import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/venture_logo.dart';
import '../../domain/entities/application_entity.dart';
import '../controllers/applications_provider.dart';

class ApplicationsListScreen extends ConsumerStatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  ConsumerState<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends ConsumerState<ApplicationsListScreen> {
  int _activeHeaderTab = 0; // 0: Active Applications, 1: Archived Decisions
  String _activeSubFilter = 'Reviewing'; // 'Reviewing' (Applied/Review), 'Shortlisted' (Shortlisted/Offered), 'Closed' (Rejected)

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Tab Selector (Active Applications vs Archived Decisions)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeHeaderTab = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeHeaderTab == 0 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Active Applications',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _activeHeaderTab == 0 ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeHeaderTab = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeHeaderTab == 1 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Archived Decisions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _activeHeaderTab == 1 ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Capsule Sub-Filters (Reviewing, Shortlisted, Closed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _subFilterPill('Reviewing'),
                    _subFilterPill('Shortlisted'),
                    _subFilterPill('Closed'),
                  ],
                ),
              ),
            ),

            // Application List matching Screen 1 format
            Expanded(
              child: applicationsAsync.when(
                data: (apps) {
                  final filteredApps = _filterApplications(apps);

                  if (filteredApps.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.assignment_outlined, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            'No applications in this category.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      final formattedDate = DateFormat('MMM d, yyyy  HH:mm:ss').format(app.appliedAt);
                      final stipendText = app.stipend;

                      return GestureDetector(
                        onTap: () {
                          context.push('/application-details', extra: app);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo
                                  VentureLogo(
                                    logoUrl: app.startupLogoUrl,
                                    name: app.startupName,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.opportunityTitle,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.text,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          app.startupName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Stipend Display
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        stipendText,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'View Process',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Applied Time:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(app.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      app.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _statusColor(app.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error loading applications: $err')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _subFilterPill(String title) {
    final isSelected = _activeSubFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSubFilter = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  List<ApplicationEntity> _filterApplications(List<ApplicationEntity> apps) {
    // 1. Separate Active vs Past
    // Active: applied, under_review, shortlisted, interview_scheduled, offered
    // Past: hired, rejected
    final isHistoryTab = _activeHeaderTab == 1;
    final tabFiltered = apps.where((app) {
      final isHistoryState = app.status == 'hired' || app.status == 'rejected';
      return isHistoryTab ? isHistoryState : !isHistoryState;
    }).toList();

    // 2. Filter by Capsule sub-filter
    // 'Reviewing': applied, under_review
    // 'Shortlisted': shortlisted, interview_scheduled, offered, hired
    // 'Closed': rejected
    return tabFiltered.where((app) {
      if (_activeSubFilter == 'Reviewing') {
        return app.status == 'applied' || app.status == 'under_review';
      } else if (_activeSubFilter == 'Shortlisted') {
        return app.status == 'shortlisted' ||
            app.status == 'interview_scheduled' ||
            app.status == 'offered' ||
            app.status == 'hired';
      } else {
        return app.status == 'rejected';
      }
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'shortlisted':
      case 'interview_scheduled':
        return AppColors.secondary;
      case 'offered':
      case 'hired':
        return AppColors.accent;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == 0) context.go('/explore');
        if (index == 1) context.go('/saved');
        if (index == 2) context.go('/applications');
        if (index == 3) context.go('/inbox');
        if (index == 4) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

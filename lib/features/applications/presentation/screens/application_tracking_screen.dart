import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/application_entity.dart';
import '../controllers/applications_provider.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  final ApplicationEntity application;

  const ApplicationTrackingScreen({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsStream = ref.watch(applicationsStreamProvider);
    
    // Find the latest state of this application from the stream
    final currentApp = appsStream.maybeWhen(
      data: (list) => list.firstWhere((a) => a.id == application.id, orElse: () => application),
      orElse: () => application,
    );

    // Reverse events list to show the latest changes at the top (or order chronologically like the screenshot: initial order is at top, in progress at bottom)
    final timelineEvents = currentApp.timeline;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Feedback/Chat',
            onPressed: () {
              context.push('/inbox', extra: currentApp);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: timelineEvents.isEmpty
            ? const Center(child: Text('No tracking events available.'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                itemCount: timelineEvents.length,
                itemBuilder: (context, index) {
                  final event = timelineEvents[index];
                  final isLast = index == timelineEvents.length - 1;

                  final dateStr = DateFormat('d MMM, yyyy').format(event.timestamp);
                  final timeStr = DateFormat('HH:mm:ss').format(event.timestamp);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time on the left hand side
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Royal Blue vertical tracking line and node
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 3,
                              height: 60, // Fixed height for vertical alignment spacing
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Right hand text content (Event title and details box)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                event.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
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

import 'package:go_router/go_router.dart';
import '../../features/opportunities/domain/entities/opportunity_entity.dart';
import '../../features/opportunities/presentation/screens/store_front_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../features/applications/domain/entities/application_entity.dart';
import '../../features/applications/presentation/screens/applications_list_screen.dart';
import '../../features/applications/presentation/screens/application_detail_screen.dart';
import '../../features/applications/presentation/screens/application_tracking_screen.dart';
import '../../features/profile/presentation/screens/options_screen.dart';

// Auth Screen Imports
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';

// Venture Portal Imports
import '../../features/opportunities/presentation/screens/owner_dashboard_screen.dart';
import '../../features/opportunities/presentation/screens/post_opportunity_screen.dart';
import '../../features/opportunities/presentation/screens/saved_screen.dart';
import '../../features/profile/presentation/screens/inbox_screen.dart';
import '../../features/opportunities/presentation/screens/apply_screen.dart';
import '../../features/auth/presentation/screens/admin_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/owner-dashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/post-opportunity',
      builder: (context, state) => const PostOpportunityScreen(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const StoreFrontScreen(),
    ),
    GoRoute(
      path: '/applications',
      builder: (context, state) => const ApplicationsListScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const OptionsScreen(),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedScreen(),
    ),
    GoRoute(
      path: '/inbox',
      builder: (context, state) {
        final initialApp = state.extra as ApplicationEntity?;
        return InboxScreen(initialApplication: initialApp);
      },
    ),
    GoRoute(
      path: '/opportunity-details',
      builder: (context, state) {
        final opp = state.extra as OpportunityEntity;
        return OpportunityDetailScreen(opportunity: opp);
      },
    ),
    GoRoute(
      path: '/apply',
      builder: (context, state) {
        final opp = state.extra as OpportunityEntity;
        return ApplyScreen(opportunity: opp);
      },
    ),
    GoRoute(
      path: '/application-details',
      builder: (context, state) {
        final app = state.extra as ApplicationEntity;
        return ApplicationDetailScreen(application: app);
      },
    ),
    GoRoute(
      path: '/application-tracking',
      builder: (context, state) {
        final app = state.extra as ApplicationEntity;
        return ApplicationTrackingScreen(application: app);
      },
    ),
  ],
);

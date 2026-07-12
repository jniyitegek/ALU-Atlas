import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState()) {
    _initUserListener();
  }

  void _initUserListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = AuthState();
      } else {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            final user = UserEntity(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: data['name'] ?? '',
              role: data['role'] ?? 'student',
              studentMajor: data['studentMajor'],
              studentCohort: data['studentCohort'],
              studentPortfolio: data['studentPortfolio'],
              profilePhotoPath: data['profilePhotoPath'],
              startupName: data['startupName'],
              startupDescription: data['startupDescription'],
              startupIndustry: data['startupIndustry'],
              startupLogoPath: data['startupLogoPath'],
              isStartupVerified: data['isStartupVerified'] ?? false,
            );
            state = state.copyWith(currentUser: user);
          }
        } catch (_) {}
      }
    });
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final user = UserEntity(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email.trim(),
          name: data['name'] ?? '',
          role: data['role'] ?? 'student',
          studentMajor: data['studentMajor'],
          studentCohort: data['studentCohort'],
          studentPortfolio: data['studentPortfolio'],
          profilePhotoPath: data['profilePhotoPath'],
          startupName: data['startupName'],
          startupDescription: data['startupDescription'],
          startupIndustry: data['startupIndustry'],
          startupLogoPath: data['startupLogoPath'],
          isStartupVerified: data['isStartupVerified'] ?? false,
        );
        state = state.copyWith(currentUser: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User profile not found in database.',
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Authentication failed.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(String email, String name, String password, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email.trim(),
        'name': name.trim(),
        'role': role,
        'isOnboarded': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newUser = UserEntity(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
      );

      state = state.copyWith(currentUser: newUser, isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Registration failed.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> completeOnboarding({
    String? major,
    String? cohort,
    String? portfolio,
    String? profilePhotoPath,
    String? startupName,
    String? startupDescription,
    String? startupIndustry,
    String? startupLogoPath,
  }) async {
    if (state.currentUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final uid = state.currentUser!.uid;
      final updates = <String, dynamic>{
        'isOnboarded': true,
      };

      if (major != null) updates['studentMajor'] = major;
      if (cohort != null) updates['studentCohort'] = cohort;
      if (portfolio != null) updates['studentPortfolio'] = portfolio;
      if (profilePhotoPath != null) updates['profilePhotoPath'] = profilePhotoPath;
      if (startupName != null) {
        updates['startupName'] = startupName;
        updates['startupDescription'] = startupDescription ?? '';
        updates['startupIndustry'] = startupIndustry ?? 'General';
        updates['startupLogoPath'] = startupLogoPath;
        updates['isStartupVerified'] = true;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);

      UserEntity updatedUser = state.currentUser!.copyWith(
        studentMajor: major,
        studentCohort: cohort,
        studentPortfolio: portfolio,
        profilePhotoPath: profilePhotoPath,
        startupName: startupName,
        startupDescription: startupDescription,
        startupIndustry: startupIndustry,
        startupLogoPath: startupLogoPath,
        isStartupVerified: startupName != null,
      );

      if (updatedUser.role == 'startup_owner' && startupName != null) {
        await FirebaseFirestore.instance.collection('startups').doc(uid).set({
          'id': uid,
          'ownerId': uid,
          'name': startupName,
          'description': startupDescription ?? '',
          'logoUrl': startupLogoPath ?? _getIndustryEmoji(startupIndustry),
          'isVerified': true,
          'domain': startupIndustry ?? 'General',
          'location': 'ALU Kigali Campus',
          'activeRolesCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      state = state.copyWith(currentUser: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateVentureProfile({
    required String name,
    required String description,
    required String industry,
    required String logoPath,
  }) async {
    if (state.currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final uid = state.currentUser!.uid;
      final updates = <String, dynamic>{
        'startupName': name,
        'startupDescription': description,
        'startupIndustry': industry,
        'startupLogoPath': logoPath,
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
      
      // Update or create the startup profile document in startups collection
      final startupDoc = FirebaseFirestore.instance.collection('startups').doc(uid);
      final startupSnap = await startupDoc.get();
      if (startupSnap.exists) {
        await startupDoc.update({
          'name': name,
          'description': description,
          'logoUrl': logoPath,
          'domain': industry,
        });
      } else {
        await startupDoc.set({
          'id': uid,
          'ownerId': uid,
          'name': name,
          'description': description,
          'logoUrl': logoPath,
          'isVerified': true,
          'domain': industry,
          'location': 'ALU Rwanda (Bumbogo)',
          'activeRolesCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ── Propagate logo/name change to all opportunity documents ──────────
      // Students read startupLogoUrl and startupName directly from opportunities,
      // so we must update every opportunity owned by this venture.
      final oppsQuery = await FirebaseFirestore.instance
          .collection('opportunities')
          .where('startupId', isEqualTo: uid)
          .get();

      if (oppsQuery.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in oppsQuery.docs) {
          batch.update(doc.reference, {
            'startupLogoUrl': logoPath,
            'startupName': name,
          });
        }
        await batch.commit();
      }

      // Update local state
      final updatedUser = state.currentUser!.copyWith(
        startupName: name,
        startupDescription: description,
        startupIndustry: industry,
        startupLogoPath: logoPath,
      );
      state = state.copyWith(currentUser: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }


  Future<void> updateProfilePhoto(String path) async {
    if (state.currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final uid = state.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePhotoPath': path,
      });

      final updatedUser = state.currentUser!.copyWith(
        profilePhotoPath: path,
      );
      state = state.copyWith(currentUser: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    state = AuthState();
  }

  String _getIndustryEmoji(String? industry) {
    if (industry == null) return '🚀';
    switch (industry.toLowerCase()) {
      case 'edtech':
        return '📚';
      case 'healthtech':
        return '🏥';
      case 'fintech':
        return '💳';
      case 'logistics tech':
      case 'logistics':
        return '📦';
      default:
        return '🚀';
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

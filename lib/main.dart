import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/routes/routes.dart';
import 'app/theme/app_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await _migrateLegacyApplications();
  } catch (e) {
    debugPrint('Migration error: $e');
  }

  runApp(
    const ProviderScope(
      child: ALUAtlasApp(),
    ),
  );
}

Future<void> _migrateLegacyApplications() async {
  final firestore = FirebaseFirestore.instance;
  
  
  final startupsSnap = await firestore.collection('startups').get();
  for (var doc in startupsSnap.docs) {
    final data = doc.data();
    final logo = data['logoUrl'] ?? '';
    if (logo.isEmpty) {
      await doc.reference.update({'logoUrl': 'assets/images/edusoma.png'});
    }
  }

 
  final oppsSnap = await firestore.collection('opportunities').get();
  for (var doc in oppsSnap.docs) {
    final data = doc.data();
    final logo = data['startupLogoUrl'] ?? '';
    if (logo.isEmpty) {
      await doc.reference.update({'startupLogoUrl': 'assets/images/edusoma.png'});
    }
  }

  final usersSnap = await firestore.collection('users').get();
  for (var doc in usersSnap.docs) {
    final data = doc.data();
    if (data['role'] == 'startup_owner') {
      final logo = data['startupLogoPath'] ?? '';
      if (logo.isEmpty) {
        final startupName = data['startupName'] ?? '';
        final newLogo = startupName.toString().toLowerCase().contains('care')
            ? 'assets/images/alucare.png'
            : startupName.toString().toLowerCase().contains('pay')
                ? 'assets/images/paytech.png'
                : 'assets/images/edusoma.png';
        await doc.reference.update({'startupLogoPath': newLogo});
      }
    }
  }


  final snap = await firestore.collection('applications').get();
  for (var doc in snap.docs) {
    final data = doc.data();
    final startupName = data['startupName'];
    final opportunityId = data['opportunityId'];
    
    
    if (startupName == null || startupName == '') {
      if (opportunityId != null) {
        final oppDoc = await firestore.collection('opportunities').doc(opportunityId).get();
        if (oppDoc.exists) {
          final oppData = oppDoc.data()!;
          await doc.reference.update({
            'startupName': oppData['startupName'] ?? 'ALU Venture',
            'startupLogoUrl': oppData['startupLogoUrl'] ?? 'assets/images/edusoma.png',
            'stipend': oppData['stipend'] ?? 'RWF 120k/mo',
          });
        } else {
          final startupId = data['startupId'] ?? '';
          await doc.reference.update({
            'startupName': startupId == 's1' ? 'EduSoma' : startupId == 's2' ? 'AluCare' : 'ALU Venture',
            'startupLogoUrl': startupId == 's1' ? 'assets/images/edusoma.png' : startupId == 's2' ? 'assets/images/alucare.png' : 'assets/images/edusoma.png',
            'stipend': startupId == 's1' ? 'RWF 120k/mo' : startupId == 's2' ? 'RWF 150k/mo' : 'RWF 120k/mo',
          });
        }
      }
      final logo = data['startupLogoUrl'] ?? '';
      if (logo.isEmpty) {
        await doc.reference.update({'startupLogoUrl': 'assets/images/edusoma.png'});
      }
    }
  }
}

class ALUAtlasApp extends StatelessWidget {
  const ALUAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ALU Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

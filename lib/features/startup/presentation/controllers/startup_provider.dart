import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/startup_entity.dart';

final startupsStreamProvider = StreamProvider<List<StartupEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('startups')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return StartupEntity(
              id: doc.id,
              ownerId: data['ownerId'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              logoUrl: data['logoUrl'] ?? '🚀',
              isVerified: data['isVerified'] ?? false,
              domain: data['domain'] ?? '',
              location: data['location'] ?? '',
              activeRolesCount: data['activeRolesCount'] ?? 0,
            );
          }).toList());
});

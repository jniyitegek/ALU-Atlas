import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/opportunity_entity.dart';

final opportunitiesStreamProvider = StreamProvider<List<OpportunityEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('opportunities')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return OpportunityEntity(
              id: doc.id,
              startupId: data['startupId'] ?? '',
              startupName: data['startupName'] ?? '',
              startupLogoUrl: data['startupLogoUrl'] ?? '',
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              requirements: List<String>.from(data['requirements'] ?? []),
              skills: List<String>.from(data['skills'] ?? []),
              status: data['status'] ?? 'open',
              type: data['type'] ?? 'Remote',
              stipend: data['stipend'] ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              requireResume: data['requireResume'] ?? true,
              requireAge: data['requireAge'] ?? false,
              requireExperience: data['requireExperience'] ?? false,
              requirePortfolio: data['requirePortfolio'] ?? false,
            );
          }).toList());
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredOpportunitiesProvider = Provider<List<OpportunityEntity>>((ref) {
  final oppsAsync = ref.watch(opportunitiesStreamProvider);
  final opportunities = oppsAsync.value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return opportunities;
  }

  return opportunities.where((opp) {
    return opp.title.toLowerCase().contains(query) ||
           opp.startupName.toLowerCase().contains(query) ||
           opp.skills.any((skill) => skill.toLowerCase().contains(query));
  }).toList();
});

/// Updates an existing opportunity document in Firestore
Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('opportunities').doc(id).update(data);
}

/// Deletes an opportunity document from Firestore
Future<void> deleteOpportunity(String id) async {
  await FirebaseFirestore.instance.collection('opportunities').doc(id).delete();
}

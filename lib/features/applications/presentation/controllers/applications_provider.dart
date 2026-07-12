import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application_entity.dart';
import '../../../opportunities/domain/entities/opportunity_entity.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

final applicationsStreamProvider = StreamProvider<List<ApplicationEntity>>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  final queryField = user.role == 'startup_owner' ? 'startupId' : 'studentId';

  return FirebaseFirestore.instance
      .collection('applications')
      .where(queryField, isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return ApplicationEntity(
              id: doc.id,
              opportunityId: data['opportunityId'] ?? '',
              studentId: data['studentId'] ?? '',
              startupId: data['startupId'] ?? '',
              startupName: data['startupName'] ?? '',
              stipend: data['stipend'] ?? '',
              startupLogoUrl: data['startupLogoUrl'] ?? '🚀',
              opportunityTitle: data['opportunityTitle'] ?? '',
              studentName: data['studentName'] ?? '',
              studentEmail: data['studentEmail'] ?? '',
              status: data['status'] ?? 'applied',
              appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              statusUpdatedAt: (data['statusUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              candidateAge: data['candidateAge'],
              candidateExperienceYears: data['candidateExperienceYears'],
              candidateResumeName: data['candidateResumeName'],
              candidatePortfolioUrl: data['candidatePortfolioUrl'],
              lastMessageText: data['lastMessageText'],
              lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
              lastMessageSenderName: data['lastMessageSenderName'],
              timeline: (data['timeline'] as List? ?? []).map((t) {
                final tData = Map<String, dynamic>.from(t);
                return TimelineEventEntity(
                  id: tData['id'] ?? '',
                  status: tData['status'] ?? '',
                  title: tData['title'] ?? '',
                  description: tData['description'] ?? '',
                  timestamp: (tData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  updatedBy: tData['updatedBy'] ?? '',
                );
              }).toList(),
            );
          }).toList());
});

final applicationsControllerProvider = Provider((ref) => ApplicationsController(ref));

class ApplicationsController {
  final Ref ref;
  ApplicationsController(this.ref);

  Future<void> submit(
    String studentId,
    String studentName,
    String studentEmail,
    OpportunityEntity opportunity, {
    int? age,
    int? experienceYears,
    String? resumeName,
    String? portfolioUrl,
  }) async {
    final appId = 'a_${DateTime.now().millisecondsSinceEpoch}';
    final docRef = FirebaseFirestore.instance.collection('applications').doc(appId);

    await docRef.set({
      'id': appId,
      'opportunityId': opportunity.id,
      'studentId': studentId,
      'startupId': opportunity.startupId,
      'startupName': opportunity.startupName,
      'stipend': opportunity.stipend,
      'startupLogoUrl': opportunity.startupLogoUrl,
      'opportunityTitle': opportunity.title,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'status': 'applied',
      'appliedAt': FieldValue.serverTimestamp(),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'candidateAge': age,
      'candidateExperienceYears': experienceYears,
      'candidateResumeName': resumeName,
      'candidatePortfolioUrl': portfolioUrl,
      'timeline': [
        {
          'id': 't_${appId}_init',
          'status': 'applied',
          'title': 'Initial Application',
          'description': 'Applied for ${opportunity.title} at ${opportunity.startupName}.',
          'timestamp': DateTime.now(),
          'updatedBy': studentId,
        }
      ],
    });
  }

  Future<void> updateStatus(String appId, String status, String comment, String updaterId) async {
    final docRef = FirebaseFirestore.instance.collection('applications').doc(appId);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final timeline = List.from(data['timeline'] ?? []);

      String title = status.toUpperCase();
      switch (status) {
        case 'under_review':
          title = 'Under Review';
          break;
        case 'shortlisted':
          title = 'Shortlisted';
          break;
        case 'interview_scheduled':
          title = 'Interview Scheduled';
          break;
        case 'offered':
          title = 'Offer Extended';
          break;
        case 'hired':
          title = 'Hired & Placed';
          break;
        case 'rejected':
          title = 'Application Closed';
          break;
      }

      timeline.add({
        'id': 't_${appId}_${DateTime.now().millisecondsSinceEpoch}',
        'status': status,
        'title': title,
        'description': comment,
        'timestamp': DateTime.now(),
        'updatedBy': updaterId,
      });

      await docRef.update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'timeline': timeline,
      });
    }
  }

  Future<void> sendChatMessage(String appId, String text) async {
    final user = ref.read(authProvider).currentUser;
    if (user == null) return;
    
    final isOwner = user.role == 'startup_owner';
    final sender = isOwner ? 'owner' : 'student';
    final senderName = user.name;
    
    final docRef = FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .collection('messages')
        .doc();
        
    await docRef.set({
      'id': docRef.id,
      'sender': sender,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .update({
      'lastMessageText': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderName': senderName,
    });
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

final applicationMessagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>((ref, appId) {
  return FirebaseFirestore.instance
      .collection('applications')
      .doc(appId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final sender = data['sender'] ?? '';
          final user = ref.read(authProvider).currentUser;
          final isOwner = user?.role == 'startup_owner';
          final isMe = (isOwner && sender == 'owner') || (!isOwner && sender == 'student');
          
          Timestamp? ts = data['timestamp'] as Timestamp?;
          DateTime time = ts != null ? ts.toDate() : DateTime.now();

          return ChatMessage(
            sender: data['senderName'] ?? '',
            text: data['text'] ?? '',
            time: time,
            isMe: isMe,
          );
        }).toList();
      });
});

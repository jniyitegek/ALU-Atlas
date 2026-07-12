class TimelineEventEntity {
  final String id;
  final String status;
  final String title;
  final String description;
  final DateTime timestamp;
  final String updatedBy;

  const TimelineEventEntity({
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.updatedBy,
  });
}

class ApplicationEntity {
  final String id;
  final String opportunityId;
  final String studentId;
  final String startupId;
  final String startupName;
  final String stipend;
  final String startupLogoUrl;
  final String opportunityTitle;
  final String studentName;
  final String studentEmail;
  final String status; // 'applied', 'under_review', 'shortlisted', 'interview_scheduled', 'offered', 'hired', 'rejected'
  final DateTime appliedAt;
  final DateTime statusUpdatedAt;
  final List<TimelineEventEntity> timeline;
  final int? candidateAge;
  final int? candidateExperienceYears;
  final String? candidateResumeName;
  final String? candidatePortfolioUrl;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderName;

  const ApplicationEntity({
    required this.id,
    required this.opportunityId,
    required this.studentId,
    required this.startupId,
    required this.startupName,
    required this.stipend,
    required this.startupLogoUrl,
    required this.opportunityTitle,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.appliedAt,
    required this.statusUpdatedAt,
    required this.timeline,
    this.candidateAge,
    this.candidateExperienceYears,
    this.candidateResumeName,
    this.candidatePortfolioUrl,
    this.lastMessageText,
    this.lastMessageTime,
    this.lastMessageSenderName,
  });

  ApplicationEntity copyWith({
    String? status,
    DateTime? statusUpdatedAt,
    List<TimelineEventEntity>? timeline,
    int? candidateAge,
    int? candidateExperienceYears,
    String? candidateResumeName,
    String? candidatePortfolioUrl,
    String? lastMessageText,
    DateTime? lastMessageTime,
    String? lastMessageSenderName,
  }) {
    return ApplicationEntity(
      id: id,
      opportunityId: opportunityId,
      studentId: studentId,
      startupId: startupId,
      startupName: startupName,
      stipend: stipend,
      startupLogoUrl: startupLogoUrl,
      opportunityTitle: opportunityTitle,
      studentName: studentName,
      studentEmail: studentEmail,
      status: status ?? this.status,
      appliedAt: appliedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      timeline: timeline ?? this.timeline,
      candidateAge: candidateAge ?? this.candidateAge,
      candidateExperienceYears: candidateExperienceYears ?? this.candidateExperienceYears,
      candidateResumeName: candidateResumeName ?? this.candidateResumeName,
      candidatePortfolioUrl: candidatePortfolioUrl ?? this.candidatePortfolioUrl,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderName: lastMessageSenderName ?? this.lastMessageSenderName,
    );
  }
}

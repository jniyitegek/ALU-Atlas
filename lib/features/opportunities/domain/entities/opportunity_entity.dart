class OpportunityEntity {
  final String id;
  final String startupId;
  final String startupName;
  final String startupLogoUrl;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> skills;
  final String status; // 'open' | 'closed'
  final String type; // 'Full-time' | 'Part-time' | 'Remote' | 'On-site'
  final String stipend;
  final DateTime createdAt;
  final bool requireResume;
  final bool requireAge;
  final bool requireExperience;
  final bool requirePortfolio;

  const OpportunityEntity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.startupLogoUrl,
    required this.title,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.status,
    required this.type,
    required this.stipend,
    required this.createdAt,
    this.requireResume = true,
    this.requireAge = false,
    this.requireExperience = false,
    this.requirePortfolio = false,
  });
}

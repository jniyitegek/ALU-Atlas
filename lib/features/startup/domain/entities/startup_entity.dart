class StartupEntity {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String logoUrl;
  final bool isVerified;
  final String domain;
  final String location;
  final int activeRolesCount;

  const StartupEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.isVerified,
    required this.domain,
    required this.location,
    required this.activeRolesCount,
  });
}

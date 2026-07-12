class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' | 'startup_owner'
  
  // Student Metadata
  final String? studentMajor;
  final String? studentCohort;
  final String? studentPortfolio;
  final String? profilePhotoPath;
  
  // Startup Owner Metadata
  final String? startupName;
  final String? startupDescription;
  final String? startupIndustry;
  final String? startupLogoPath;
  final bool isStartupVerified;

  UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.studentMajor,
    this.studentCohort,
    this.studentPortfolio,
    this.profilePhotoPath,
    this.startupName,
    this.startupDescription,
    this.startupIndustry,
    this.startupLogoPath,
    this.isStartupVerified = false,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? studentMajor,
    String? studentCohort,
    String? studentPortfolio,
    String? profilePhotoPath,
    String? startupName,
    String? startupDescription,
    String? startupIndustry,
    String? startupLogoPath,
    bool? isStartupVerified,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      studentMajor: studentMajor ?? this.studentMajor,
      studentCohort: studentCohort ?? this.studentCohort,
      studentPortfolio: studentPortfolio ?? this.studentPortfolio,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      startupName: startupName ?? this.startupName,
      startupDescription: startupDescription ?? this.startupDescription,
      startupIndustry: startupIndustry ?? this.startupIndustry,
      startupLogoPath: startupLogoPath ?? this.startupLogoPath,
      isStartupVerified: isStartupVerified ?? this.isStartupVerified,
    );
  }
}

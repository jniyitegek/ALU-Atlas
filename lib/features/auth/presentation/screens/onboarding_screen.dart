import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Student specific controllers
  final _majorController = TextEditingController();
  final _cohortController = TextEditingController();
  final _portfolioController = TextEditingController();
  String? _selectedProfilePath;

  // Startup Owner specific controllers
  final _startupNameController = TextEditingController();
  final _startupDescriptionController = TextEditingController();
  String _selectedIndustry = 'EdTech';
  String? _selectedLogoPath;

  @override
  void dispose() {
    _majorController.dispose();
    _cohortController.dispose();
    _portfolioController.dispose();
    _startupNameController.dispose();
    _startupDescriptionController.dispose();
    super.dispose();
  }

  void _handleOnboardingSubmit() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser == null) return;

      if (currentUser.role == 'student') {
        await ref.read(authProvider.notifier).completeOnboarding(
              major: _majorController.text.trim(),
              cohort: _cohortController.text.trim(),
              portfolio: _portfolioController.text.trim(),
              profilePhotoPath: _selectedProfilePath,
            );
        if (mounted) context.go('/explore');
      } else {
        await ref.read(authProvider.notifier).completeOnboarding(
              startupName: _startupNameController.text.trim(),
              startupDescription: _startupDescriptionController.text.trim(),
              startupIndustry: _selectedIndustry,
              startupLogoPath: _selectedLogoPath,
            );
        if (mounted) context.go('/owner-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User session not found.')),
      );
    }

    final isStudent = user.role == 'student';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isStudent ? 'Student Onboarding' : 'Venture Setup',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isStudent
                    ? 'Let ALU ventures know your academic specialization and portfolio details.'
                    : 'Configure your startup profile so student candidates can see venture details.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: isStudent
                    ? Column(
                        children: [
                          // Profile Photo Picker
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        _selectedProfilePath = image.path;
                                      });
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: AppColors.primary.withOpacity(0.08),
                                    backgroundImage: _selectedProfilePath != null
                                        ? FileImage(File(_selectedProfilePath!))
                                        : null,
                                    child: _selectedProfilePath == null
                                        ? const Icon(Icons.add_a_photo_outlined, size: 30, color: AppColors.primary)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Upload Profile Photo (Local)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Major Field
                          TextFormField(
                            controller: _majorController,
                            decoration: InputDecoration(
                              labelText: 'Academic Major (e.g. Software Engineering)',
                              prefixIcon: const Icon(Icons.school_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your academic major';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Cohort Field
                          TextFormField(
                            controller: _cohortController,
                            decoration: InputDecoration(
                              labelText: 'Academic Cohort (e.g. ALU Kigali 2026)',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your cohort year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Portfolio URL Field
                          TextFormField(
                            controller: _portfolioController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: 'Portfolio / GitHub Link (Optional)',
                              prefixIcon: const Icon(Icons.link_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Venture Logo Picker
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        _selectedLogoPath = image.path;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: _selectedLogoPath != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.file(File(_selectedLogoPath!), fit: BoxFit.cover),
                                          )
                                        : const Icon(Icons.add_photo_alternate_outlined, size: 30, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Upload Venture Logo (Local)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Startup Name Field
                          TextFormField(
                            controller: _startupNameController,
                            decoration: InputDecoration(
                              labelText: 'Venture Name',
                              prefixIcon: const Icon(Icons.business_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your venture name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Startup Industry Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedIndustry,
                            decoration: InputDecoration(
                              labelText: 'Industry Sector',
                              prefixIcon: const Icon(Icons.category_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: ['EdTech', 'HealthTech', 'FinTech', 'Logistics Tech', 'Other']
                                .map((industry) => DropdownMenuItem(
                                      value: industry,
                                      child: Text(industry),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedIndustry = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Startup Description
                          TextFormField(
                            controller: _startupDescriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Venture Description / Bio',
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 60.0),
                                child: Icon(Icons.description_outlined),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a short venture description';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // Onboarding Submit Button
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleOnboardingSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Complete Profile Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

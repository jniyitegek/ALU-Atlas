import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/opportunity_entity.dart';
import '../../../applications/presentation/controllers/applications_provider.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final OpportunityEntity opportunity;

  const ApplyScreen({
    super.key,
    required this.opportunity,
  });

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _ageController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  String? _selectedResumeName;
  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Mutesi Keza');
    _emailController = TextEditingController(text: user?.email ?? 'm.keza@alu.edu');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _simulateResumeUpload() async {
    setState(() {
      _isUploadingResume = true;
    });
    // Simulate network delay for uploading CV
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _selectedResumeName = 'CV_Resume_${_nameController.text.replaceAll(' ', '_')}.pdf';
        _isUploadingResume = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CV/Resume PDF attached successfully!'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      if (widget.opportunity.requireResume && _selectedResumeName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your CV/Resume PDF to apply.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final user = ref.read(authProvider).currentUser;
      final studentId = user?.uid ?? 'stud1';

      ref.read(applicationsControllerProvider).submit(
        studentId,
        _nameController.text.trim(),
        _emailController.text.trim(),
        widget.opportunity,
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
        experienceYears: _experienceController.text.isNotEmpty ? int.tryParse(_experienceController.text) : null,
        resumeName: _selectedResumeName,
        portfolioUrl: _portfolioController.text.trim().isNotEmpty ? _portfolioController.text.trim() : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted to ${widget.opportunity.startupName}!'),
          backgroundColor: AppColors.accent,
        ),
      );

      context.go('/applications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Info
                Text(
                  'Applying for ${opp.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Venture: ${opp.startupName} • Stipend: ${opp.stipend}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),

                // Age (Conditional)
                if (opp.requireAge) ...[
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age Eligibility',
                      hintText: 'e.g. 21',
                      prefixIcon: const Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (opp.requireAge && (val == null || val.isEmpty)) {
                        return 'Venture owner requires age details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Experience (Conditional)
                if (opp.requireExperience) ...[
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Years of Experience',
                      hintText: 'e.g. 2',
                      prefixIcon: const Icon(Icons.trending_up_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (opp.requireExperience && (val == null || val.isEmpty)) {
                        return 'Venture owner requires experience info';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Portfolio Link (Conditional)
                if (opp.requirePortfolio) ...[
                  TextFormField(
                    controller: _portfolioController,
                    decoration: InputDecoration(
                      labelText: 'Portfolio / GitHub URL',
                      hintText: 'e.g. github.com/username',
                      prefixIcon: const Icon(Icons.link_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (opp.requirePortfolio && (val == null || val.isEmpty)) {
                        return 'Venture owner requires portfolio link';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Resume Upload Dropzone (Conditional)
                if (opp.requireResume) ...[
                  const Text(
                    'CV / Professional Resume',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isUploadingResume ? null : _simulateResumeUpload,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedResumeName != null ? AppColors.accent : AppColors.border,
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedResumeName != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                            size: 40,
                            color: _selectedResumeName != null ? AppColors.accent : AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedResumeName ?? 'Tap to select & upload CV (PDF)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedResumeName != null ? AppColors.accent : AppColors.text,
                            ),
                          ),
                          if (_isUploadingResume) ...[
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

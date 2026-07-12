import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/opportunity_entity.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _skillsController = TextEditingController();
  final _stipendController = TextEditingController();

  String _selectedType = 'Remote';
  bool _requireResume = true;
  bool _requireAge = false;
  bool _requireExperience = false;
  bool _requirePortfolio = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _skillsController.dispose();
    _stipendController.dispose();
    super.dispose();
  }

  void _submitOpportunity() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).currentUser;
      if (user == null) return;

      final startupName = user.startupName ?? 'My Startup';
      final startupLogo = user.startupLogoPath ??
          (user.startupIndustry == 'EdTech'
              ? '📚'
              : user.startupIndustry == 'HealthTech'
                  ? '🏥'
                  : user.startupIndustry == 'FinTech'
                      ? '💳'
                      : '📦');

      final newOpp = OpportunityEntity(
        id: 'o_${DateTime.now().millisecondsSinceEpoch}',
        startupId: user.uid,
        startupName: startupName,
        startupLogoUrl: startupLogo,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
        skills: _skillsController.text
            .split(',')
            .map((skill) => skill.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        status: 'open',
        type: _selectedType,
        stipend: 'RWF ${_stipendController.text.trim()}/month',
        createdAt: DateTime.now(),
        requireResume: _requireResume,
        requireAge: _requireAge,
        requireExperience: _requireExperience,
        requirePortfolio: _requirePortfolio,
      );

      // Add to Firestore database
      FirebaseFirestore.instance.collection('opportunities').doc(newOpp.id).set({
        'id': newOpp.id,
        'startupId': newOpp.startupId,
        'startupName': newOpp.startupName,
        'startupLogoUrl': newOpp.startupLogoUrl,
        'title': newOpp.title,
        'description': newOpp.description,
        'requirements': newOpp.requirements,
        'skills': newOpp.skills,
        'status': newOpp.status,
        'type': newOpp.type,
        'stipend': newOpp.stipend,
        'createdAt': Timestamp.fromDate(newOpp.createdAt),
        'requireResume': newOpp.requireResume,
        'requireAge': newOpp.requireAge,
        'requireExperience': newOpp.requireExperience,
        'requirePortfolio': newOpp.requirePortfolio,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opportunity posted successfully!'),
          backgroundColor: AppColors.accent,
        ),
      );

      context.pop(); // Return to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post Opportunity'),
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
                const Text(
                  'Create Internship Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Define position details, requirements, and monthly stipend compensation.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Opportunity Title',
                    hintText: 'e.g. Flutter Mobile Developer Intern',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Role Description',
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
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Requirements (one per line)
                TextFormField(
                  controller: _requirementsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Requirements (one per line)',
                    hintText: 'Familiar with state management\nGood communication skills',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Icon(Icons.list_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter requirements';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Skills (comma separated)
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                    labelText: 'Core Skills (comma separated)',
                    hintText: 'Flutter, Dart, Firebase, Git',
                    prefixIcon: const Icon(Icons.offline_bolt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter key skills';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Job Type Selector
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Job Type',
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['Remote', 'Onsite', 'Hybrid', 'Part-time', 'Full-time']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Stipend Field
                TextFormField(
                  controller: _stipendController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monthly Stipend (RWF)',
                    hintText: 'e.g. 150000',
                    prefixText: 'RWF ',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify stipend compensation';
                    }
                    return null;
                  },
                ),
                // Configure Form Requirements Card
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.assignment_ind_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Required Application Fields',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set what candidate credentials students must submit to apply for this internship.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Require CV/Resume upload', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Forces candidates to attach a PDF document.', style: TextStyle(fontSize: 11)),
                        value: _requireResume,
                        onChanged: (value) => setState(() => _requireResume = value),
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Require Candidate Age', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Forces candidate to specify age eligibility.', style: TextStyle(fontSize: 11)),
                        value: _requireAge,
                        onChanged: (value) => setState(() => _requireAge = value),
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Require Experience Years', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Forces candidate to indicate field experience.', style: TextStyle(fontSize: 11)),
                        value: _requireExperience,
                        onChanged: (value) => setState(() => _requireExperience = value),
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Require Portfolio link', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Forces candidate to specify portfolio/GitHub link.', style: TextStyle(fontSize: 11)),
                        value: _requirePortfolio,
                        onChanged: (value) => setState(() => _requirePortfolio = value),
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Publish Position',
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
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../../../applications/presentation/controllers/applications_provider.dart';
import '../controllers/opportunities_provider.dart';
import '../../domain/entities/opportunity_entity.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Unauthorized')));
    }

    final oppsAsync = ref.watch(opportunitiesStreamProvider);
    final allOpps = oppsAsync.value ?? [];
    final ventureOpps = allOpps.where((o) => o.startupId == user.uid).toList();
    final appsAsync = ref.watch(applicationsStreamProvider);

    final logoPath = user.startupLogoPath ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Venture Portal'),
        automaticallyImplyLeading: false,
        actions: [
          // Settings shortcut
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Venture Settings',
            onPressed: () => _showVentureEditSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Venture Profile Card (tap to edit) ──────────────────────
          GestureDetector(
            onTap: () => _showVentureEditSheet(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  // Logo with edit badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                          color: AppColors.primary.withOpacity(0.06),
                        ),
                        child: ClipOval(child: _buildLogoWidget(logoPath, 56)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.startupName ?? 'Unnamed Venture',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                            ),
                            if (user.isStartupVerified)
                              const Icon(Icons.verified, color: AppColors.primary, size: 16),
                          ],
                        ),
                        if (user.startupIndustry?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(user.startupIndustry!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                        if (user.startupDescription?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(user.startupDescription!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Visual edit cue
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Tabs ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tab('Venture Roles (${ventureOpps.length})', 0),
                const SizedBox(width: 8),
                _tab('Candidates Log', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tab Content ─────────────────────────────────────────────
          Expanded(
            child: _activeTab == 0
                ? _buildRoles(context, ventureOpps)
                : appsAsync.when(
                    data: (all) => _buildCandidates(context, all.where((a) => a.startupId == user.uid).toList()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/post-opportunity'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Opportunity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // ── Tab button ───────────────────────────────────────────────────────────
  Widget _tab(String label, int index) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? Colors.white : AppColors.text)),
        ),
      ),
    );
  }

  // ── Roles List ───────────────────────────────────────────────────────────
  Widget _buildRoles(BuildContext context, List<OpportunityEntity> opps) {
    if (opps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('No active postings yet.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            const Text('Tap "+ Post Opportunity" below to create one.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: opps.length,
      itemBuilder: (context, index) {
        final opp = opps[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Role header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _chip(opp.type, AppColors.primary),
                              const SizedBox(width: 8),
                              _chip(opp.stipend, Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit and Delete buttons
                    Column(
                      children: [
                        _iconBtn(Icons.edit_outlined, AppColors.primary, () => _showRoleEditSheet(context, opp)),
                        const SizedBox(height: 4),
                        _iconBtn(Icons.delete_outline, Colors.redAccent, () => _confirmDelete(context, opp)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Description
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(opp.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              // Application requirements row
              if (opp.requireResume || opp.requireAge || opp.requireExperience || opp.requirePortfolio)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (opp.requireResume) _reqChip('Resume'),
                      if (opp.requireAge) _reqChip('Age'),
                      if (opp.requireExperience) _reqChip('Experience'),
                      if (opp.requirePortfolio) _reqChip('Portfolio'),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Candidates List ──────────────────────────────────────────────────────
  Widget _buildCandidates(BuildContext context, List apps) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('No applications received yet.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: apps.length,
      itemBuilder: (context, i) {
        final app = apps[i];
        return GestureDetector(
          onTap: () => context.push('/application-details', extra: app),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text('Role: ${app.opportunityTitle}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(app.studentEmail, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(app.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(app.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(app.status))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Venture Edit Sheet ───────────────────────────────────────────────────
  void _showVentureEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _VentureEditSheet(),
    );
  }

  // ── Role Edit Sheet ──────────────────────────────────────────────────────
  void _showRoleEditSheet(BuildContext context, OpportunityEntity opp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoleEditSheet(opp: opp),
    );
  }

  // ── Delete confirmation ──────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, OpportunityEntity opp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Role?'),
        content: Text('Are you sure you want to delete "${opp.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await deleteOpportunity(opp.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role deleted.')));
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _buildLogoWidget(String path, double size) {
    if (path.isEmpty) return Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55));
    if (path.startsWith('/') || path.contains('content://')) {
      return Image.file(File(path), fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55)));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55)));
    }
    return Center(child: Text(path, style: TextStyle(fontSize: size * 0.45)));
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _reqChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
      child: Text('Req: $label', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'under_review': return Colors.orange;
      case 'shortlisted':
      case 'interview_scheduled': return AppColors.secondary;
      case 'offered':
      case 'hired': return AppColors.accent;
      case 'rejected': return Colors.red;
      default: return Colors.blue;
    }
  }
}

// ── Venture Edit Sheet Widget ────────────────────────────────────────────────

class _VentureEditSheet extends ConsumerStatefulWidget {
  const _VentureEditSheet();

  @override
  ConsumerState<_VentureEditSheet> createState() => _VentureEditSheetState();
}

class _VentureEditSheetState extends ConsumerState<_VentureEditSheet> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _industry;
  String? _logoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider).currentUser;
    _name = TextEditingController(text: u?.startupName ?? '');
    _desc = TextEditingController(text: u?.startupDescription ?? '');
    _industry = TextEditingController(text: u?.startupIndustry ?? '');
    _logoPath = u?.startupLogoPath;
  }

  @override
  void dispose() {
    _name.dispose(); _desc.dispose(); _industry.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _logoPath = img.path);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venture name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateVentureProfile(
        name: _name.text.trim(),
        description: _desc.text.trim(),
        industry: _industry.text.trim().isEmpty ? 'General' : _industry.text.trim(),
        logoPath: _logoPath ?? '🚀',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Venture profile saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _logoPreview(double size) {
    final path = _logoPath ?? '';
    if (path.isEmpty) return Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52));
    if (path.startsWith('/') || path.contains('content://')) {
      return Image.file(File(path), fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52)));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52)));
    }
    return Center(child: Text(path, style: TextStyle(fontSize: size * 0.42)));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: ListView(
          controller: sc,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Row(children: [
              const Expanded(child: Text('Edit Venture Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),

            // Logo picker
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2.5), color: AppColors.primary.withOpacity(0.06)),
                      child: ClipOval(child: _logoPreview(100)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Tap logo to pick from gallery (saved locally)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            const SizedBox(height: 24),

            _field(_name, 'Venture Name *'),
            const SizedBox(height: 14),
            _field(_industry, 'Industry / Domain', hint: 'e.g. EdTech, HealthTech, FinTech'),
            const SizedBox(height: 14),
            _field(_desc, 'Description / Bio', hint: 'What does your venture do?', maxLines: 4),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Venture Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {String? hint, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Role/Opportunity Edit Sheet ──────────────────────────────────────────────

class _RoleEditSheet extends StatefulWidget {
  final OpportunityEntity opp;
  const _RoleEditSheet({required this.opp});

  @override
  State<_RoleEditSheet> createState() => _RoleEditSheetState();
}

class _RoleEditSheetState extends State<_RoleEditSheet> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _stipend;
  late String _type;
  late bool _requireResume;
  late bool _requireAge;
  late bool _requireExperience;
  late bool _requirePortfolio;
  bool _saving = false;

  final _types = ['Remote', 'Hybrid', 'On-site'];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.opp.title);
    _desc = TextEditingController(text: widget.opp.description);
    _stipend = TextEditingController(text: widget.opp.stipend);
    _type = widget.opp.type;
    _requireResume = widget.opp.requireResume;
    _requireAge = widget.opp.requireAge;
    _requireExperience = widget.opp.requireExperience;
    _requirePortfolio = widget.opp.requirePortfolio;
  }

  @override
  void dispose() {
    _title.dispose(); _desc.dispose(); _stipend.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role title is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      await updateOpportunity(widget.opp.id, {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'stipend': _stipend.text.trim(),
        'type': _type,
        'requireResume': _requireResume,
        'requireAge': _requireAge,
        'requireExperience': _requireExperience,
        'requirePortfolio': _requirePortfolio,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Role updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: ListView(
          controller: sc,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Row(children: [
              const Expanded(child: Text('Edit Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),

            _field(_title, 'Role Title *'),
            const SizedBox(height: 14),
            _field(_stipend, 'Stipend / Compensation', hint: 'e.g. RWF 180,000/month'),
            const SizedBox(height: 14),

            // Type selector
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Work Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 14),
            _field(_desc, 'Role Description', hint: 'Describe responsibilities and expectations', maxLines: 4),

            const SizedBox(height: 20),
            const Text('Application Requirements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 4),
            const Text('Toggle which documents applicants must submit:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),

            _toggle('Require Resume / CV', _requireResume, (v) => setState(() => _requireResume = v)),
            _toggle('Require Age Declaration', _requireAge, (v) => setState(() => _requireAge = v)),
            _toggle('Require Work Experience', _requireExperience, (v) => setState(() => _requireExperience = v)),
            _toggle('Require Portfolio / GitHub', _requirePortfolio, (v) => setState(() => _requirePortfolio = v)),

            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Role Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {String? hint, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        dense: true,
      ),
    );
  }
}

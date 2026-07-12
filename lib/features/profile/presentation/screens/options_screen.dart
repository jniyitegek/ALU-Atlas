import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  ConsumerState<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    final isOwner = user?.role == 'startup_owner';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Gradient Hero Header ───────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6A0DAD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              child: Column(
                children: [
                  // Profile photo with camera overlay
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => _pickProfilePhoto(context),
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white24,
                          ),
                          child: ClipOval(
                            child: _buildAvatarContent(
                                user?.profilePhotoPath, user?.name),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _pickProfilePhoto(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Icon(Icons.camera_alt_outlined,
                              color: AppColors.primary, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Tap photo to change',
                      style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(user?.email ?? '',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      isOwner ? ' Venture Owner' : ' Student Candidate',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  // ── Venture Card (owners only) ──────────────────────
                  if (isOwner) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _showVentureProfileSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white54, width: 2),
                                    color: Colors.white12,
                                  ),
                                  child: ClipOval(
                                    child: _buildLogoWidget(
                                        user?.startupLogoPath,
                                        size: 60),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.edit_outlined,
                                      color: AppColors.primary, size: 11),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.startupName ?? 'My Venture',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (user?.startupIndustry?.isNotEmpty == true)
                                        ? user!.startupIndustry!
                                        : 'Tap to add industry',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      'Edit Venture Profile →',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Settings Sections ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel('Account'),
                  _card([
                    _item(
                      icon: Icons.person_outline,
                      title: 'Personal Info',
                      subtitle: 'View name, email and role',
                      onTap: () => _showPersonalInfoSheet(context),
                    ),
                    if (isOwner)
                      _item(
                        icon: Icons.business_outlined,
                        title: 'Venture Profile',
                        subtitle: 'Name, logo, description & industry',
                        onTap: () => _showVentureProfileSheet(context),
                        isLast: true,
                      )
                    else ...[
                      _item(
                        icon: Icons.assignment_outlined,
                        title: 'My Applications',
                        subtitle: 'Track your submitted applications',
                        onTap: () => context.go('/applications'),
                      ),
                      _item(
                        icon: Icons.description_outlined,
                        title: 'Resume & Credentials',
                        subtitle: 'Manage academic documents',
                        onTap: () => _showResumeSheet(context),
                        isLast: true,
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('Wallet & Finance'),
                  _card([
                    _item(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'ALU Atlas Wallet',
                      subtitle: 'Balance, transactions & virtual card',
                      onTap: () => _showWalletSheet(context),
                    ),
                    _item(
                      icon: Icons.smartphone_outlined,
                      title: 'Mobile Stipend Routing',
                      subtitle: 'Configure MoMo payment settings',
                      onTap: () => _showMobileStipendSheet(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.fingerprint,
                              color: AppColors.text, size: 22),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Wallet Biometric',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text)),
                                Text('Fingerprint to authorise payments',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _biometricEnabled,
                            onChanged: (val) =>
                                setState(() => _biometricEnabled = val),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('Support'),
                  _card([
                    _item(
                      icon: Icons.star_outline,
                      title: 'Rate ALU Atlas',
                      subtitle: 'Share your feedback',
                      onTap: () => _showRatingDialog(context),
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.redAccent, size: 18),
                    label: const Text('Sign Out',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('ALU Atlas © 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 4),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _pickProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      try {
        await ref.read(authProvider.notifier).updateProfilePhoto(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile photo updated!')));
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildAvatarContent(String? path, String? name) {
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('/') || path.contains('content://')) {
        return Image.file(File(path),
            fit: BoxFit.cover,
            width: 92,
            height: 92,
            errorBuilder: (_, __, ___) => _initials(name));
      }
      if (path.startsWith('assets/')) {
        return Image.asset(path,
            fit: BoxFit.cover,
            width: 92,
            height: 92,
            errorBuilder: (_, __, ___) => _initials(name));
      }
    }
    return _initials(name);
  }

  Widget _initials(String? name) {
    return Center(
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
        style: const TextStyle(
            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildLogoWidget(String? path, {double size = 90}) {
    if (path == null || path.isEmpty) {
      return Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55));
    }
    if (path.startsWith('/') || path.contains('content://')) {
      return Image.file(File(path),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55)));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.business, color: AppColors.primary, size: size * 0.55)));
    }
    return Center(child: Text(path, style: TextStyle(fontSize: size * 0.42)));
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))
              : null,
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 13, color: AppColors.textSecondary),
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        if (!isLast) const Divider(indent: 70, endIndent: 16, height: 1),
      ],
    );
  }

  // ── Sheets ───────────────────────────────────────────────────────────────

  void _showPersonalInfoSheet(BuildContext context) {
    final user = ref.read(authProvider).currentUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Personal Info',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text)),
            const SizedBox(height: 16),
            _infoRow('Full Name', user?.name ?? '—'),
            const Divider(),
            _infoRow('Email', user?.email ?? '—'),
            const Divider(),
            _infoRow(
                'Platform Role',
                user?.role == 'startup_owner'
                    ? 'Venture Owner'
                    : 'Student Candidate'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Close',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showResumeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Academic Credentials',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: const Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resume.pdf',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('PDF Document • 1.2 MB',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resume replaced!')));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Replace PDF',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ALU Atlas Wallet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6A0DAD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVAILABLE BALANCE',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('RWF 150,000',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text('ALU Atlas Virtual ID Card',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
            ),
            const SizedBox(height: 16),
            const Text('Recent Ledger',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('EduSoma Internship Stipend',
                    style: TextStyle(fontSize: 13)),
                Text('+RWF 120,000',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ecosystem Cafeteria Remera',
                    style: TextStyle(fontSize: 13)),
                Text('-RWF 3,000',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileStipendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mobile Stipend Routing',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            const Text(
                'Configure direct transfer of stipend funds to your mobile money wallet.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _infoRow('Carrier', 'MTN Mobile Money Rwanda'),
            const Divider(),
            _infoRow('Number', '+250 788 123 456'),
            const Divider(),
            _infoRow('Status', 'Active & Verified ✓'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings confirmed!')));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Confirm Settings',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rate ALU Atlas', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Your feedback helps us connect ALU startups with talent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                icon: const Icon(Icons.star,
                    color: AppColors.secondary, size: 36),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Thanks for ${index + 1} stars!'),
                      backgroundColor: AppColors.accent));
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showVentureProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VentureProfileModalContent(),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == 0) context.go('/explore');
        if (index == 1) context.go('/saved');
        if (index == 2) context.go('/applications');
        if (index == 3) context.go('/inbox');
        if (index == 4) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined), label: 'Explore'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline), label: 'Saved'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), label: 'Applications'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

// ── Venture Profile Edit Modal ───────────────────────────────────────────────

class VentureProfileModalContent extends ConsumerStatefulWidget {
  const VentureProfileModalContent({super.key});

  @override
  ConsumerState<VentureProfileModalContent> createState() =>
      _VentureProfileModalContentState();
}

class _VentureProfileModalContentState
    extends ConsumerState<VentureProfileModalContent> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _industryController;
  String? _pickedLogoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).currentUser;
    _nameController = TextEditingController(text: user?.startupName ?? '');
    _descController =
        TextEditingController(text: user?.startupDescription ?? '');
    _industryController =
        TextEditingController(text: user?.startupIndustry ?? '');
    _pickedLogoPath = user?.startupLogoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedLogoPath = image.path);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venture name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateVentureProfile(
            name: name,
            description: _descController.text.trim(),
            industry: _industryController.text.trim().isNotEmpty
                ? _industryController.text.trim()
                : 'General',
            logoPath: _pickedLogoPath ?? '🚀',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Venture profile saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildLogoPreview(String? path, double size) {
    if (path == null || path.isEmpty) {
      return Center(child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52));
    }
    if (path.startsWith('/') || path.contains('content://')) {
      return Image.file(File(path),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52)));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.business, color: AppColors.primary, size: size * 0.52)));
    }
    return Center(child: Text(path, style: TextStyle(fontSize: size * 0.42)));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 20),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                    child: Text('Edit Venture Profile',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text))),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),

            // Logo picker
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primary, width: 2.5),
                        color: AppColors.primary.withOpacity(0.06),
                      ),
                      child: ClipOval(
                          child: _buildLogoPreview(_pickedLogoPath, 100)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('Tap logo to pick from gallery',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Venture Name *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _industryController,
              decoration: InputDecoration(
                labelText: 'Industry / Domain',
                hintText: 'e.g. EdTech, HealthTech, FinTech',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description / Bio',
                hintText: 'What does your venture do?',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Venture Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

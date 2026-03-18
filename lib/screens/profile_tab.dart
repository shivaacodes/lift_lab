import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/storage_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.profile, required this.onProfileUpdated});
  final UserModel? profile;
  final Future<void> Function() onProfileUpdated;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _auth = AuthService();
  final _db = DatabaseService();
  final _storage = StorageService();
  final _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();
  String _gender = 'Male';

  String? _pendingImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _initControllers();
  }

  void _initControllers() {
    final p = widget.profile;
    final user = _auth.currentUser;
    if (_nameCtrl.text.isEmpty && p != null) {
      _nameCtrl.text = p.name;
    } else if (_nameCtrl.text.isEmpty && user != null) {
      _nameCtrl.text = (user.email ?? 'Member').split('@').first;
    }
    
    _pendingImageUrl = p?.profileImageUrl;
    
    if (_ageCtrl.text.isEmpty && p != null) _ageCtrl.text = '${p.metrics['age'] ?? ''}';
    _gender = p?.metrics['gender'] ?? 'Male';
    if (_sleepCtrl.text.isEmpty && p != null) _sleepCtrl.text = '${p.lifestyle['sleep'] ?? ''}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image == null) return;

    setState(() => _isUploading = true);
    HapticsService.light();

    try {
      final url = await _storage.uploadProfileImage(File(image.path));
      setState(() {
        _pendingImageUrl = url;
        _isUploading = false;
      });
      HapticsService.success();
      showBottomToast(context, 'Image uploaded! Save to apply.');
    } catch (e) {
      setState(() => _isUploading = false);
      HapticsService.error();
      showBottomToast(context, 'Upload failed: $e');
    }
  }

  void _save() {
    final user = _auth.currentUser;
    if (user == null) return;

    showBottomToast(context, 'Updating profile...');
    HapticsService.selection();

    _db.updateUserProfileFields(
      user.uid,
      name: _nameCtrl.text.trim(),
      profileImageUrl: _pendingImageUrl,
      metrics: {
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'gender': _gender,
      },
      lifestyle: {'sleep': double.tryParse(_sleepCtrl.text.trim()) ?? 7.0},
    ).then((_) {
      HapticsService.success();
      widget.onProfileUpdated();
      if (mounted) showBottomToast(context, '✨ Profile updated and synced!', isSuccess: true);
    }).catchError((e) {
      HapticsService.error();
      if (mounted) showBottomToast(context, e.toString(), isError: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = _auth.currentUser?.email ?? 'member@liftlab.app';
    final image = _pendingImageUrl ?? '';
    final initial = (_nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : email)[0].toUpperCase();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Profile', style: theme.textTheme.displayLarge?.copyWith(fontSize: 32)),
          const SizedBox(height: 32),

          // ── Account Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x0D000000), width: 1.5),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        image: (image.isNotEmpty) 
                            ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) 
                            : null,
                      ),
                      child: image.isEmpty 
                          ? Center(child: Text(initial, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.primary))) 
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('Active License Member', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
          
          const SizedBox(height: 24),

          // ── Details Form ────────────────────────────────────────────
          InfoCard(
            title: 'Personal Metrics',
            order: 1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _sleepCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sleep Target (h)'))),
              ]),
              const SizedBox(height: 24),
              const Text('GENDER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black38)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _MiniGenderCard(
                    label: 'Male', 
                    isSelected: _gender == 'Male', 
                    onTap: () { HapticsService.selection(); setState(() => _gender = 'Male'); }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniGenderCard(
                    label: 'Female', 
                    isSelected: _gender == 'Female', 
                    onTap: () { HapticsService.selection(); setState(() => _gender = 'Female'); }
                  ),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _save, 
            child: const Text('SAVE CHANGES'),
          ),
          
          const SizedBox(height: 12),
          
          OutlinedButton.icon(
            onPressed: () async {
              HapticsService.medium();
              await _auth.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('SIGN OUT'),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _MiniGenderCard extends StatelessWidget {
  const _MiniGenderCard({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isSelected ? theme.colorScheme.primary : Colors.black45,
          )),
        ),
      ),
    );
  }
}

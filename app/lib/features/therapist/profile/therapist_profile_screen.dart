import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/auth_service.dart';
import '../../../services/app_state.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  // Dynamic data loaded from Firestore
  String _specialty = '';
  String _bio = '';
  double? _rating;
  int _reviewCount = 0;
  String _patientsCount = '—';
  String _experience = '—';
  String _satisfaction = '—';
  List<String> _specialties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
    _loadTherapistData();
  }

  void _onStateChange() { if (mounted) setState(() {}); }

  Future<void> _loadTherapistData() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(uid)
          .get();
      if (!mounted) return;
      final data = doc.data() ?? {};
      setState(() {
        _specialty = (data['specialty'] as String?)?.isNotEmpty == true
            ? data['specialty'] as String
            : 'Clinical Psychologist';
        _bio = (data['bio'] as String?)?.isNotEmpty == true
            ? data['bio'] as String
            : 'Passionate about helping patients achieve mental wellness through evidence-based therapy and a compassionate approach.';
        final r = data['rating'];
        final rv = r != null ? (r as num).toDouble() : 0.0;
        _rating = rv > 0 ? rv : null;
        _reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
        final pc = data['patientsCount'];
        _patientsCount = pc != null ? '$pc' : '—';
        final exp = data['experience'] as String?;
        _experience = exp?.isNotEmpty == true ? exp! : '—';
        final sat = data['satisfaction'] as String?;
        _satisfaction = sat?.isNotEmpty == true ? sat! : '—';
        final sp = data['specialties'];
        if (sp is List) {
          _specialties = sp.whereType<String>().toList();
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  String get _name => AppState.instance.userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF7F89E9))),
                    )
                  : Column(
                      children: [
                        Text(
                          _name,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF292929),
                            fontSize: 22.564,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _specialty,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF595959),
                            fontSize: 13.538,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_rating != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFCC991A), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _rating!.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFCC991A),
                                  fontSize: 15.795,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_reviewCount > 0)
                                Text(
                                  ' ($_reviewCount reviews)',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF595959),
                                    fontSize: 12.41,
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _StatCard(value: _patientsCount, label: 'Patients')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatCard(value: _experience, label: 'Experience')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatCard(value: _satisfaction, label: 'Satisfaction')),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _buildSection(
                          title: 'About',
                          child: Text(
                            _bio,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF595959),
                              fontSize: 13.538,
                              height: 1.6,
                            ),
                          ),
                        ),
                        if (_specialties.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          _buildSection(
                            title: 'Specialties',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _specialties
                                  .map(
                                    (t) => Container(
                                      height: 31.59,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF7F89E9),
                                          width: 1.128,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.795),
                                      ),
                                      child: Center(
                                        child: Text(
                                          t,
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF7F89E9),
                                            fontSize: 12.41,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        _buildSection(
                          title: 'Schedule & Settings',
                          child: _SettingsGroup(tiles: [
                            _SettingsTile(
                              icon: Icons.calendar_month_outlined,
                              label: 'Availability & Schedule',
                              onTap: () => _showAvailabilitySheet(context),
                            ),
                            _SettingsTile(
                              icon: Icons.notifications_outlined,
                              label: 'Notification Preferences',
                              onTap: () => _showComingSoon(context, 'Notification Preferences'),
                            ),
                            _SettingsTile(
                              icon: Icons.lock_outline_rounded,
                              label: 'Privacy & Security',
                              onTap: () => _showComingSoon(context, 'Privacy & Security'),
                            ),
                            _SettingsTile(
                              icon: Icons.help_outline_rounded,
                              label: 'Help & Support',
                              onTap: () => _showHelpSheet(context),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () async {
                            await AuthService.signOut();
                            AppState.instance.clearState();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/role-selection');
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 49.641,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.923),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18.051,
                                  offset: const Offset(0, 4.513),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded,
                                    color: Color(0xFFD93333), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Log Out',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFD93333),
                                    fontSize: 14.667,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 248.205,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22.56, 24.82, 22, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Profile',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22.564,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfile(context),
                        child: Container(
                          width: 58.667,
                          height: 33.846,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
                            ),
                            borderRadius: BorderRadius.circular(16.923),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1),
                          ),
                          child: Center(
                            child: Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  padding: const EdgeInsets.all(6.77),
                  child: UserAvatar(
                    radius: 58.667,
                    backgroundColor: const Color(0xFFA87CC7),
                    fontSize: 31.59,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAvailabilitySheet(BuildContext context) {
    bool available = true;
    final uid = AuthService.currentUser?.uid;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              22, 14, 22, 24 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD2D5DE),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Text('Availability & Schedule',
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF292929))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Available for sessions',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: const Color(0xFF292929))),
                    ),
                    Switch(
                      value: available,
                      activeThumbColor: const Color(0xFF7F89E9),
                      onChanged: (v) async {
                        setLocal(() => available = v);
                        if (uid != null) {
                          await FirebaseFirestore.instance
                              .collection('therapists')
                              .doc(uid)
                              .set({'available': v}, SetOptions(merge: true));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Working Hours',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF292929))),
                    const SizedBox(height: 8),
                    Text('Mon – Fri  ·  9:00 AM – 5:00 PM',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: const Color(0xFF595959))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xFF7F89E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFD2D5DE),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Help & Support',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF292929))),
            const SizedBox(height: 20),
            _HelpTile(icon: Icons.email_outlined, label: 'Contact Support',
                subtitle: 'support@mentallico.app'),
            const SizedBox(height: 10),
            _HelpTile(icon: Icons.menu_book_outlined, label: 'Documentation',
                subtitle: 'Therapist guide & FAQs'),
            const SizedBox(height: 10),
            _HelpTile(icon: Icons.bug_report_outlined, label: 'Report an Issue',
                subtitle: 'Let us know what went wrong'),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final specialtyCtrl = TextEditingController(text: _specialty);
    final bioCtrl = TextEditingController(text: _bio);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD2D5DE),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Edit Profile',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E12))),
              const SizedBox(height: 18),
              _buildField('Specialty', specialtyCtrl, maxLines: 1),
              const SizedBox(height: 12),
              _buildField('Bio', bioCtrl, maxLines: 4),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final uid = AuthService.currentUser?.uid;
                  if (uid != null) {
                    await FirebaseFirestore.instance
                        .collection('therapists')
                        .doc(uid)
                        .set({
                      'specialty': specialtyCtrl.text.trim(),
                      'bio': bioCtrl.text.trim(),
                    }, SetOptions(merge: true));
                    if (mounted) {
                      setState(() {
                        _specialty = specialtyCtrl.text.trim();
                        _bio = bioCtrl.text.trim();
                      });
                    }
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text('Save Changes',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF595959),
            )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD2D5DE)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            cursorColor: const Color(0xFF7F89E9),
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF292929)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF292929),
            fontSize: 16.923,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 67.692,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.923),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.051,
            offset: const Offset(0, 4.513),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF7F89E9),
              fontSize: 20.308,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF595959),
              fontSize: 11.282,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> tiles;
  const _SettingsGroup({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.923),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.051,
            offset: const Offset(0, 4.513),
          ),
        ],
      ),
      child: Column(children: tiles),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.923),
        child: Container(
          height: 49.641,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: const Color(0xFFD2D5DE).withValues(alpha: 0.5),
                  width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7F89E9), size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF292929),
                    fontSize: 14.667,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFD2D5DE), size: 18.051),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _HelpTile(
      {required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF7F89E9), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF292929))),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF595959))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD2D5DE), size: 18),
        ],
      ),
    );
  }
}

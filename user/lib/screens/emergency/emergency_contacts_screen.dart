import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_widgets.dart';

class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String name;
  final String phone;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyContact> _contacts = const [
    EmergencyContact(
      name: 'Campus Security (New Site)',
      phone: '+2348031234567',
      category: 'Security',
      description: 'BUK main security headquarters control room, New Site.',
      icon: PhosphorIconsRegular.shield,
      color: Color(0xFFE63946),
    ),
    EmergencyContact(
      name: 'Campus Security (Old Site)',
      phone: '+2348039876543',
      category: 'Security',
      description: 'Senate building secondary security gate, Old Site campus.',
      icon: PhosphorIconsRegular.shieldWarning,
      color: Color(0xFFE63946),
    ),
    EmergencyContact(
      name: 'BUK Medical Clinic Center',
      phone: '+2348123456789',
      category: 'Medical',
      description: 'Primary healthcare center and emergency ambulance dispatcher.',
      icon: PhosphorIconsRegular.pulse,
      color: Color(0xFF10B981),
    ),
    EmergencyContact(
      name: 'Student Affairs Welfare Helpline',
      phone: '+2348055551212',
      category: 'Welfare',
      description: 'Inquiries, lost students support, and emergency student lodging assistance.',
      icon: PhosphorIconsRegular.users,
      color: Color(0xFF3B82F6),
    ),
    EmergencyContact(
      name: 'Faculty Helpline Coordinator',
      phone: '+2348099887766',
      category: 'Welfare',
      description: 'Academic issues assistance, exam emergencies and classroom incidents.',
      icon: PhosphorIconsRegular.graduationCap,
      color: Color(0xFF8B5CF6),
    ),
    EmergencyContact(
      name: 'Kano State Fire Service Centre',
      phone: '+23464123456',
      category: 'Public Response',
      description: 'General metropolitan fire and emergency response services.',
      icon: PhosphorIconsRegular.fire,
      color: Color(0xFFF59E0B),
    ),
    EmergencyContact(
      name: 'National Police Control Command',
      phone: '112',
      category: 'Public Response',
      description: 'Federal toll-free emergency crime dispatcher line.',
      icon: PhosphorIconsRegular.phone,
      color: Color(0xFF1E293B),
    ),
  ];

  String _filterActive = 'All';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch dialer intent';
      }
    } catch (_) {
      // Fallback in case dialer isn't supported (e.g. tablet, emulator, custom OS build)
      _showCallFallback(phoneNumber);
    }
  }

  void _showCallFallback(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$phoneNumber" to clipboard. Dialer is unavailable.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  List<EmergencyContact> get _filteredContacts {
    if (_filterActive == 'All') return _contacts;
    return _contacts.where((c) => c.category == _filterActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS Emergency banner call trigger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _makePhoneCall('112'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PhosphorIconsRegular.phoneCall,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOS EMERGENCY CALL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Tap to call national emergency services (112) immediately.',
                                style: TextStyle(
                                  color: Color(0xDDFFFFFF),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          PhosphorIconsRegular.caretRight,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Action filters chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All'),
                  const SizedBox(width: 8),
                  _filterChip('Security'),
                  const SizedBox(width: 8),
                  _filterChip('Medical'),
                  const SizedBox(width: 8),
                  _filterChip('Welfare'),
                  const SizedBox(width: 8),
                  _filterChip('Public Response'),
                ],
              ),
            ),
          ),

          // Contacts List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _filteredContacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _filteredContacts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFF1F4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x040D1B2D),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Category Icon Badge
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(c.icon, color: const Color(0xFF334155), size: 20),
                        ),
                        const SizedBox(width: 14),
                        
                        // Name and details text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(AppColors.primaryDeeper),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                c.description,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.phone,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Direct Call CTA button (Circular Blue call trigger)
                        ClipOval(
                          child: Material(
                            color: const Color(AppColors.primaryDeeper).withOpacity(0.08),
                            child: InkWell(
                              onTap: () => _makePhoneCall(c.phone),
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  PhosphorIconsRegular.phoneCall,
                                  color: Color(AppColors.primaryDeeper),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterActive == label;
    return GestureDetector(
      onTap: () => setState(() => _filterActive = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(AppColors.primaryDeeper) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(AppColors.textSecondary),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
const Color Colors_whiteAA = Color(0xDDFFFFFF);
extension ColorExtensions on Color {
  static const Color whiteAA = Colors_whiteAA;
}

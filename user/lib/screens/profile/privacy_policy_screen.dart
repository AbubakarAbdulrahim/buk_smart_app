import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(AppColors.darkBackground) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.darkCard) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                ),
                boxShadow: isDark
                    ? []
                    : [
                        const BoxShadow(color: Color(0x040B1A2B), blurRadius: 8, offset: Offset(0, 2)),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsRegular.shieldCheck,
                          color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Privacy & Security',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bayero University Kano • Student Data Protection',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bayero University Kano is committed to safeguarding student privacy and protecting all personal, academic, and interaction records stored within the SmartBUK system.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '1',
              title: 'Information We Collect',
              content:
                  'We collect information you provide directly during registration and usage, including:\n• Student Profile: Full Name, Student Reg. Number, Department, Faculty, Level, and BUK email.\n• Incident & Emergency Reports: Description, campus location tags, and optional attached photographs.\n• Lost & Found Listings: Item descriptions, locations found, and contact references.\n• Smart AI Conversations: Questions and context queries submitted to the assistant for response generation.',
            ),

            const SizedBox(height: 14),

            // Section 2
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '2',
              title: 'How We Use Your Information',
              content:
                  'Your data is utilized strictly for university operations and student support:\n• Authenticating your identity and academic status.\n• Routing incident and emergency alerts to university security personnel for rapid intervention.\n• Facilitating matchmaking and return of lost items on campus.\n• Personalizing academic resources, past questions, and departmental opportunities.\n• Analyzing aggregate, anonymized campus statistics to improve university services.',
            ),

            const SizedBox(height: 14),

            // Section 3
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '3',
              title: 'Data Storage & Encryption',
              content:
                  'All personal data is encrypted both in transit (TLS/HTTPS) and at rest utilizing Google Cloud / Firebase Enterprise infrastructure. Incident photos and attachments are securely stored with restricted access tokens. Passwords are never stored in plaintext and are protected by industry-standard cryptographic hashing.',
            ),

            const SizedBox(height: 14),

            // Section 4
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '4',
              title: 'Third-Party Disclosure & Sharing',
              content:
                  'Bayero University Kano does not sell, trade, or monetize student personal data under any circumstances. Information is only disclosed to authorized campus units (Security Directorate, Dean of Student Affairs, CITS) when required for student welfare, emergency response, or disciplinary procedures under university statute.',
            ),

            const SizedBox(height: 14),

            // Section 5
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '5',
              title: 'Smart AI Query Privacy',
              content:
                  'Conversations with the Smart AI assistant are processed securely. Chat history is stored locally and in user-scoped database partitions. AI logs are not shared externally or used for commercial AI training datasets.',
            ),

            const SizedBox(height: 14),

            // Section 6
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '6',
              title: 'Student Rights & Account Deletion',
              content:
                  'Students retain the right to view, modify, or correct their personal profile information via the Edit Profile screen. You may also request removal of your lost & found postings or reported items once resolved. For full account or data deletion requests, contact the CITS Helpdesk.',
            ),

            const SizedBox(height: 14),

            // Section 7
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '7',
              title: 'Contact the Data Protection Officer',
              content:
                  'If you have questions regarding your data privacy, security practices, or wish to report a privacy concern, please contact:\n\nCentre for Information Technology and Services (CITS)\nBayero University, New Campus, Kano\nEmail: cits@buk.edu.ng • security@buk.edu.ng',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(AppColors.darkCard) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

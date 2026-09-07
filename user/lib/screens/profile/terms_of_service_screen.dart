import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
            // Header summary banner
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
                          PhosphorIconsRegular.fileText,
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
                              'Bayero University, Kano',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Last Updated: August 2026 • Version 1.0.0',
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
                    'Please read these Terms of Service carefully before accessing or using the SmartBUK student mobile application and digital campus services.',
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
              title: 'Acceptance of Terms',
              content:
                  'By registering, installing, or interacting with the SmartBUK application, you acknowledge that you are a currently enrolled student, staff member, or authorized affiliate of Bayero University Kano (BUK), and agree to comply with all applicable university IT regulations, academic codes, and campus security policies.',
            ),

            const SizedBox(height: 14),

            // Section 2
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '2',
              title: 'User Accounts & Authentication',
              content:
                  'You are solely responsible for maintaining the confidentiality of your student login credentials (Registration Number, BUK email address, and Password). Any actions taken under your authenticated profile are your responsibility. Impersonating other students or creating unauthorized accounts is strictly prohibited and subject to university disciplinary review.',
            ),

            const SizedBox(height: 14),

            // Section 3
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '3',
              title: 'Incident Reporting & Campus Safety',
              content:
                  'The Emergency and Incident Reporting features are provided to facilitate campus safety and rapid assistance. Submitting false alarms, defamatory reports, malicious hoaxes, or misleading security alerts will result in immediate suspension of account privileges and referral to the University Security Directorate and Student Disciplinary Committee.',
            ),

            const SizedBox(height: 14),

            // Section 4
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '4',
              title: 'Lost & Found Guidelines',
              content:
                  'Items posted on the Lost & Found portal must be accurate and authentic. When claiming a lost item, students are required to verify ownership by providing matching identifying details (such as National ID, Student Card, or specific description). Any fraudulent claims will be treated as property theft under university law.',
            ),

            const SizedBox(height: 14),

            // Section 5
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '5',
              title: 'Smart AI Assistant & Academic Integrity',
              content:
                  'The Smart AI assistant is intended as an educational companion, providing study guidance, course information, and campus assistance. Students must uphold Bayero University\'s academic integrity guidelines and ensure that AI interactions are not used for exam malpractice or unethical submission practices.',
            ),

            const SizedBox(height: 14),

            // Section 6
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '6',
              title: 'Intellectual Property & Resources',
              content:
                  'All past questions, handbooks, departmental guidelines, and university resources made available through SmartBUK are property of Bayero University Kano or their respective academic departments. These resources are licensed solely for personal, non-commercial academic study by BUK students.',
            ),

            const SizedBox(height: 14),

            // Section 7
            _buildSectionCard(
              context: context,
              isDark: isDark,
              number: '7',
              title: 'Modifications & Contact',
              content:
                  'The Centre for Information Technology and Services (CITS) reserves the right to amend these Terms at any time. Continued use of the application after changes constitutes acceptance. For inquiries or technical assistance, contact CITS at cits@buk.edu.ng.',
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

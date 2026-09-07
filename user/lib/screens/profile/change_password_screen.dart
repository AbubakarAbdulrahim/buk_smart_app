import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  Color _getStrengthColor(double strength, bool isDark) {
    if (strength <= 0.25) return isDark ? const Color(AppColors.darkDanger) : const Color(0xFFEF4444);
    if (strength <= 0.5) return isDark ? const Color(AppColors.darkWarning) : const Color(0xFFF59E0B);
    if (strength <= 0.75) return isDark ? const Color(AppColors.primaryLight) : const Color(0xFF3B82F6);
    return isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF10B981);
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.0) return '';
    if (strength <= 0.25) return 'Too weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthService>();

    try {
      await auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        final str = e.toString().toLowerCase();
        if (str.contains('wrong-password') || str.contains('invalid-credential')) {
          _errorMessage = 'The current password you entered is incorrect.';
        } else if (str.contains('weak-password')) {
          _errorMessage = 'The new password is too weak. Please use a stronger combination.';
        } else if (str.contains('requires-recent-login')) {
          _errorMessage = 'Security timeout. Please log out and sign in again before changing password.';
        } else {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        }
      });
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(AppColors.darkCard) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.checkCircle,
                  color: isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF16A34A),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Password Changed!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account password has been updated securely. You can now use your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to settings
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.read<AuthService>().currentUser;
    final strength = _calculateStrength(_newPasswordController.text);
    final strengthColor = _getStrengthColor(strength, isDark);
    final strengthText = _getStrengthText(strength);

    return Scaffold(
      backgroundColor: isDark ? const Color(AppColors.darkBackground) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security info header card
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
                child: Row(
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Security',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose a strong password with letters, numbers, and symbols to protect your account.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.warningCircle,
                        color: isDark ? const Color(AppColors.darkDanger) : const Color(AppColors.danger),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: isDark ? const Color(AppColors.darkDanger) : const Color(AppColors.danger),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 1. Current Password
              _buildFieldLabel('Current Password', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                style: TextStyle(
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hint: 'Enter your current password',
                  isDark: isDark,
                  prefixIcon: PhosphorIconsRegular.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                      size: 18,
                      color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Current password is required' : null,
              ),

              // Forgot password recovery link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.forgotPassword,
                      arguments: user?.email,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot current password?',
                    style: TextStyle(
                      color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. New Password
              _buildFieldLabel('New Password', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onChanged: (val) => setState(() {}),
                style: TextStyle(
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hint: 'Create a new password',
                  isDark: isDark,
                  prefixIcon: PhosphorIconsRegular.lockKey,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                      size: 18,
                      color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'New password is required';
                  if (v.trim().length < 6) return 'Must be at least 6 characters long';
                  if (v.trim() == _currentPasswordController.text.trim()) {
                    return 'New password must be different from current password';
                  }
                  return null;
                },
              ),

              // Strength Indicator bar
              if (_newPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: strength,
                          backgroundColor: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      strengthText,
                      style: TextStyle(
                        color: strengthColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 18),

              // 3. Confirm Password
              _buildFieldLabel('Confirm New Password', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: TextStyle(
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(
                  hint: 'Re-enter new password',
                  isDark: isDark,
                  prefixIcon: PhosphorIconsRegular.checkSquareOffset,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                      size: 18,
                      color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your new password';
                  if (v != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required bool isDark,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      filled: true,
      fillColor: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
      prefixIcon: Icon(
        prefixIcon,
        size: 18,
        color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF64748B),
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(AppColors.darkDanger) : const Color(AppColors.danger),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(AppColors.darkDanger) : const Color(AppColors.danger),
          width: 1.5,
        ),
      ),
    );
  }
}

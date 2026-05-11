import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _sending = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      await context.read<AuthService>().sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to send reset link.';
      if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else if (e.code == 'user-not-found') {
        message = 'No account found for this email.';
      } else if (e.code == 'configuration-not-found') {
        message = AppStrings.authConfigMissing;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.genericError)),
      );
    }

    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _sent ? _buildSuccessState() : _buildFormState(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Color(0x120085D0),
              child: Icon(
                Icons.lock_reset_rounded,
                color: Color(AppColors.primaryDeeper),
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Reset Your Password',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Enter your university email and we will send you a reset link to regain access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(AppColors.textSecondary), height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(
              hintText: 'student@buk.edu.ng',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Send Reset Link',
            onPressed: _sendResetLink,
            isLoading: _sending,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: CircleAvatar(
            radius: 34,
            backgroundColor: Color(0x120085D0),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: Color(AppColors.primaryDeeper),
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(
          width: double.infinity,
          child: Text(
            'Check Your Email',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Text(
            'We sent a password reset link to ${_emailController.text.trim()}. Open your email app and follow the instructions.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(AppColors.textSecondary), height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _sendResetLink,
            child: const Text('Resend Link'),
          ),
        ),
      ],
    );
  }
}

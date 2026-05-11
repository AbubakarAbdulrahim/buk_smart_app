import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _matricNumber = TextEditingController();
  final _faculty = TextEditingController();
  final _department = TextEditingController();
  String? _selectedLevel;
  bool _isLogin = true;
  bool _loading = false;
  bool _hidePassword = true;

  static const List<String> _levels = <String>[
    '100 Level',
    '200 Level',
    '300 Level',
    '400 Level',
    '500 Level',
    'Postgraduate',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _matricNumber.dispose();
    _faculty.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final email = _email.text.trim();
    final password = _password.text.trim();

    try {
      if (_isLogin) {
        await auth.signIn(email: email, password: password);
      } else {
        await auth.signUp(email: email, password: password);
      }

      final user = auth.currentUser;
      if (user != null) {
        await firestore.ensureUserProfile(
          uid: user.uid,
          email: user.email ?? email,
          name: _isLogin ? null : _name.text.trim(),
          matricNumber: _isLogin ? null : _matricNumber.text.trim(),
          faculty: _isLogin ? null : _faculty.text.trim(),
          department: _isLogin ? null : _department.text.trim(),
          level: _isLogin ? null : _selectedLevel,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed. Please try again.';
      if (e.code == 'configuration-not-found') {
        message = AppStrings.authConfigMissing;
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.genericError)));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _isLogin
                        ? Image.asset(
                            'assets/images/buk_logo.png',
                            width: 86,
                            height: 86,
                            fit: BoxFit.contain,
                          )
                        : const CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0x120085D0),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(AppColors.primaryDeeper),
                              size: 30,
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _isLogin
                          ? 'Use your university email to continue.'
                          : 'Create an account to access campus services and updates.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(AppColors.textSecondary), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isLogin) ...[
                    const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _name,
                      validator: (value) => _isLogin ? null : Validators.requiredField(value, 'Name'),
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      hintText: 'student@buk.edu.ng',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      hintText: _isLogin ? 'Enter your password' : 'Create a secure password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    const Text('Matric Number', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _matricNumber,
                      validator: (value) => Validators.requiredField(value, 'Matric Number'),
                      decoration: const InputDecoration(
                        hintText: 'Enter your matric number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Faculty', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _faculty,
                      validator: (value) => Validators.requiredField(value, 'Faculty'),
                      decoration: const InputDecoration(
                        hintText: 'Enter your faculty',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Department', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _department,
                      validator: (value) => Validators.requiredField(value, 'Department'),
                      decoration: const InputDecoration(
                        hintText: 'Enter your department',
                        prefixIcon: Icon(Icons.apartment_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Level', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      validator: (value) => value == null || value.isEmpty ? 'Level is required' : null,
                      decoration: const InputDecoration(
                        hintText: 'Select your level',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: _levels
                          .map((level) => DropdownMenuItem<String>(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedLevel = value),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use at least 6 characters. A stronger password keeps your account safer.',
                      style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(
                                initialEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  if (!_isLogin) const SizedBox(height: 18),
                  AppButton(
                    label: _isLogin ? 'Login' : 'Register',
                    onPressed: _submit,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _isLogin = !_isLogin;
                        if (_isLogin) {
                          _selectedLevel = null;
                        }
                      }),
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Register'
                            : 'Already have an account? Login',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

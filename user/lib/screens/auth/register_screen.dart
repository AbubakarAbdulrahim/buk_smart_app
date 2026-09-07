import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/success_modal.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _matricNumber = TextEditingController();
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedLevel;
  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const List<String> _levels = <String>[
    '100 Level',
    '200 Level',
    '300 Level',
    '400 Level',
    '500 Level',
    '600 Level',
    'Postgraduate',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _matricNumber.dispose();
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
      await auth.signUp(email: email, password: password);

      final user = auth.currentUser;
      if (user != null) {
        final registeredName = _name.text.trim();
        try {
          await user.updateDisplayName(registeredName);
        } catch (_) {}
        await firestore.ensureUserProfile(
          uid: user.uid,
          email: user.email ?? email,
          name: registeredName,
          matricNumber: _matricNumber.text.trim(),
          faculty: _selectedFaculty,
          department: _selectedDepartment,
          program: _selectedProgram,
          level: _selectedLevel,
        );
      }
      if (!mounted) return;
      await showSuccessModal(
        context: context,
        title: 'Registration Successful',
        message: 'Your SmartBUK account has been created successfully. Welcome to your campus super app.',
        buttonLabel: 'Continue',
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed. Please try again.';
      if (e.code == 'configuration-not-found') {
        message = AppStrings.authConfigMissing;
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
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
                  const Center(
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0x120085D0),
                      child: Icon(
                        PhosphorIconsRegular.userPlus,
                        color: Color(AppColors.primaryDeeper),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: Text(
                  //     'Create an account to access campus services and updates.',
                  //     textAlign: TextAlign.center,
                  //     style: const TextStyle(color: Color(AppColors.textSecondary), height: 1.4),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    validator: (value) => Validators.requiredField(value, 'Name'),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(PhosphorIconsRegular.user),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      hintText: 'student@gmail.com',
                      prefixIcon: Icon(PhosphorIconsRegular.envelope),
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
                      hintText: 'Create password',
                      prefixIcon: const Icon(PhosphorIconsRegular.lock),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPassword,
                    obscureText: _hideConfirmPassword,
                    validator: (value) {
                      final required = Validators.requiredField(value, 'Confirm Password');
                      if (required != null) return required;
                      if (value != _password.text) return 'Passwords do not match';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      prefixIcon: const Icon(PhosphorIconsRegular.lock),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                        icon: Icon(_hideConfirmPassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Matric Number', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _matricNumber,
                    validator: (value) => Validators.requiredField(value, 'Matric Number'),
                    decoration: const InputDecoration(
                      hintText: 'Enter your matric number',
                      prefixIcon: Icon(PhosphorIconsRegular.creditCard),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Faculty', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedFaculty,
                    validator: (value) => value == null || value.isEmpty ? 'Faculty is required' : null,
                    decoration: const InputDecoration(
                       hintText: 'Select your faculty',
                       prefixIcon: Icon(PhosphorIconsRegular.bank),
                    ),
                    items: AppData.faculties
                        .map((faculty) => DropdownMenuItem<String>(
                              value: faculty,
                              child: Text(faculty),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedFaculty = value;
                      _selectedDepartment = null;
                      _selectedProgram = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text('Department', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedDepartment,
                    validator: (value) => value == null || value.isEmpty ? 'Department is required' : null,
                    decoration: InputDecoration(
                      hintText: _selectedFaculty == null ? 'Select faculty first' : 'Select your department',
                      prefixIcon: const Icon(PhosphorIconsRegular.building),
                    ),
                    items: AppData.departmentsFor(_selectedFaculty)
                        .map((department) => DropdownMenuItem<String>(
                              value: department,
                              child: Text(department),
                            ))
                        .toList(),
                    onChanged: _selectedFaculty == null
                        ? null
                        : (value) => setState(() {
                              _selectedDepartment = value;
                              _selectedProgram = null;
                            }),
                  ),
                  const SizedBox(height: 16),
                  const Text('Program', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedProgram,
                    validator: (value) => value == null || value.isEmpty ? 'Program is required' : null,
                    decoration: InputDecoration(
                      hintText: _selectedDepartment == null ? 'Select department first' : 'Select your program',
                      prefixIcon: const Icon(PhosphorIconsRegular.bookOpen),
                    ),
                    items: AppData.programsFor(_selectedFaculty, _selectedDepartment)
                        .map((program) => DropdownMenuItem<String>(
                              value: program,
                              child: Text(program),
                            ))
                        .toList(),
                    onChanged: _selectedDepartment == null ? null : (value) => setState(() => _selectedProgram = value),
                  ),
                  const SizedBox(height: 16),
                  const Text('Level', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedLevel,
                    validator: (value) => value == null || value.isEmpty ? 'Level is required' : null,
                    decoration: const InputDecoration(
                      hintText: 'Select your level',
                      prefixIcon: Icon(PhosphorIconsRegular.graduationCap),
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
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Register',
                    onPressed: _submit,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                      },
                      child: const Text('Already have an account? Login'),
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

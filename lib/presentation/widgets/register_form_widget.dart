import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neffils/domain/repositories/register_repository.dart';
import 'package:neffils/presentation/screens/home_screen/home_navbar_screen.dart';
import 'package:neffils/presentation/screens/auth/login_screen.dart';
import 'package:neffils/utils/colors/color.dart';

import '../../domain/usecases/register_usecase.dart';

class RegisterForm extends StatefulWidget {
  final RegisterRepository authRepository;

  const RegisterForm({super.key, required this.authRepository});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscureText = true;
  bool _agreedToPolicy = false;
  bool _isLoading = false;

  // Field error messages from API
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearApiErrors() {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the privacy policy')),
      );
      return;
    }

    _clearApiErrors();
    setState(() => _isLoading = true);

    try {
      final useCase = RegisterUseCase(widget.authRepository);
      await useCase.execute(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      // Handle API validation errors
      if (e is Map<String, dynamic>) {
        setState(() {
          _usernameError = e['username']?.first;
          _emailError = e['email']?.first;
          _phoneError = e['phone_number']?.first;
          _passwordError = e['password']?.first;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Full Name '),
              TextSpan(text: '( पुरा नाम )'),
            ]),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration('Enter your full name'),
          ),
          const SizedBox(height: 6),

          // Username Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Username '),
              TextSpan(text: '( प्रयोगकर्ता नाम )'),
            ]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username is required';
              }
              return null;
            },
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration('Enter your username'),
          ),
          if (_usernameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _usernameError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),

          // Email Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Email '),
              TextSpan(text: '( इमेल )'),
            ]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration('Enter your email'),
          ),
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _emailError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),

          // Phone Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Phone '),
              TextSpan(text: '( फोन )'),
            ]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _phoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration('Enter your phone'),
          ),
          if (_phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _phoneError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),

          // Password Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Password '),
              TextSpan(text: '( पासवर्ड )'),
            ]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration(
              'Enter password',
              isPassword: true,
              onSuffixPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            ),
          ),
          if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _passwordError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),

          // Confirm Password Field
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Confirm Password '),
              TextSpan(text: '( पासवर्ड पुष्टि गर्नुहोस् )'),
            ]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            style: const TextStyle(fontSize: 13),
            decoration: _buildInputDecoration(
              'Re-enter password',
              isPassword: true,
              onSuffixPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            ),
          ),
          const SizedBox(height: 5),

          // Privacy Policy Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreedToPolicy,
                  side: BorderSide(color: appColors.white_black),
                  activeColor: appColors.formsubmit,
                  checkColor: Colors.white,
                  onChanged: (value) {
                    setState(() => _agreedToPolicy = value ?? false);
                  },
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: Text(
                    'I agree to privacy policy & terms. ( म गोपनीयता नीति र सर्तहरूमा सहमत छु। )',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // Register Button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.formsubmit,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _register,
            child: const Text(
              'Register ( दर्ता गर्नुहोस् ) ',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          // Login Link
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(
                        color: appColors.formsubmit,
                        fontSize: 13,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(
                      text: " ( पहिले नै खाता छ? ",
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    TextSpan(
                      text: " लगइन ",
                      style: const TextStyle(
                        color: appColors.formsubmit,
                        fontSize: 13,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(
                      text: " गर्नुहोस् )",
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String labelText, {
        bool isPassword = false,
        VoidCallback? onSuffixPressed,
      }) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelText: labelText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: appColors.dimwhite, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: appColors.formsubmit, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      labelStyle: const TextStyle(color: appColors.white_black),
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: appColors.white_black,
        ),
        onPressed: onSuffixPressed,
      )
          : null,
    );
  }
}
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neffils/ui/color_manager.dart';
import 'package:neffils/ui/styles_manager.dart';
import 'package:neffils/ui/values_manager.dart';
import 'package:provider/provider.dart';
import 'package:neffils/data/repositories/login_repository_impl.dart';
import 'package:neffils/presentation/screens/auth/password_screen/forgot_password_screen.dart';
import 'package:neffils/presentation/screens/home_screen/home_navbar_screen.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/login_auth_api_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../utils/colors/color.dart';
import '../screens/auth/register_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;

  late LoginUseCase loginUseCase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = LoginAuthApiService(authProvider);
    loginUseCase = LoginUseCase(LoginRepositoryImpl(authService));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '* ',
                  style: getBoldStyle(
                    color: Colors.red,
                  ),
                ),
                TextSpan(
                  text: 'Email / Username / Phone No ',
                  style: getSemiBoldStyle(),
                ),
                TextSpan(
                  text: '( इमेल / प्रयोगकर्ता नाम / फोन नम्बर )',
                  style: getSemiBoldStyle(fontSize: AppSize.s10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            style: getRegularStyle(
              fontSize: AppSize.s12,
            ),
            cursorColor: ColorManager.primary,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Invalid email address, username or phone no';
              }
              return null;
            },
            controller: _username,
            decoration: const InputDecoration(
              hintText: 'Enter valid email address, username or phone no.',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          // Text.rich(
          //   const TextSpan(children: [
          //     TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
          //     TextSpan(text: 'Password '),
          //     TextSpan(text: '( पासवर्ड )'),
          //   ]),
          // ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '* ',
                  style: getBoldStyle(
                    color: Colors.red,
                  ),
                ),
                TextSpan(
                  text: 'Password',
                  style: getSemiBoldStyle(),
                ),
                TextSpan(
                  text: ' ( पासवर्ड )',
                  style: getSemiBoldStyle(fontSize: AppSize.s10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          TextFormField(
            controller: _password,
            obscureText: _obscureText,
            style: getRegularStyle(
              fontSize: AppSize.s12,
            ),
            cursorColor: ColorManager.primary,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Invalid password';
              }
              return null;
            },
            // controller: _username,
            decoration: InputDecoration(
              hintText: 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: appColors.white_black,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                'Forgot Password ( पासवर्ड बिर्सनुभयो ?)',
                style: getSemiBoldStyle(
                  color: ColorManager.primary,
                  fontSize: AppSize.s10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.primary,
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.formsubmit,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _loading = true);
                      try {
                        final user = await loginUseCase.execute(
                          _username.text.trim(),
                          _password.text,
                        );

                        // Get the latest authProvider from context
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.login(user);

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeNavbarScreen(username: user.username),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    }
                  },
                  child: Text(
                    'Login to account ( खातामा लगइन गर्नुहोस् )',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: getRegularStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: "Register Now",
                      style: getRegularStyle(
                        color: ColorManager.primary,
                        fontSize: 13,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "( खाता छैन? ",
                  style: getRegularStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: " दर्ता गर्नुहोस् )",
                      style: const TextStyle(
                        color: appColors.formsubmit,
                        fontSize: 13,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
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

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/password_widget/forgot_password_form_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo/mainlogo.png', height: 80),
              const SizedBox(height: 10),
              const Text(
                "Forget Password ( पासवर्ड बिर्सनुभयो? )",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              const Text(
                " Enter the username, and we'll send you password reset OTP on your registered email.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "(  प्रयोगकर्ता नाम प्रविष्ट गर्नुहोस्, र हामी तपाईंको दर्ता गरिएको इमेलमा पासवर्ड रिसेट OTP पठाउनेछौं। )",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const ForgotPasswordForm(),
          ],
        ),
      ),
    )
    );
  }
}
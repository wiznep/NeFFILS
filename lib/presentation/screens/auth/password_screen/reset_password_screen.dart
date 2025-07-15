import 'package:flutter/material.dart';
import 'package:neffils/presentation/widgets/password_widget/reset_password_form_wdget.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
                const SizedBox(height: 16),
                const Text(
                  "Create Your New Password ( आफ्नो नयाँ पासवर्ड सिर्जना गर्नुहोस् )",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const ResetPasswordForm(),
              ],
            ),
          )
      ),
    );
  }
}
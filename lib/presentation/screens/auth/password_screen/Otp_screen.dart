import 'package:flutter/material.dart';

import '../../../widgets/password_widget/otp_form_widget.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
                "Enter Your OTP ( आफ्नो ओटीपी प्रविष्ट गर्नुहोस्। )",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                " We've sent a one-time password (OTP) to your email. Check your inbox (and maybe your spam folder!) to find the code, and enter it below to reset your password.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "( हामीले तपाईंको इमेलमा एक पटकको पासवर्ड (OTP) पठाएका छौं। कोड फेला पार्न आफ्नो इनबक्स (र सायद तपाईंको स्प्याम फोल्डर!) जाँच गर्नुहोस्, र आफ्नो पासवर्ड रिसेट गर्न तल प्रविष्ट गर्नुहोस्। )",
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const OtpForm(),
            ],
          ),
        )
      ),
    );
  }
}
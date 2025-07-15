import 'package:flutter/material.dart';
import 'package:neffils/ui/styles_manager.dart';
import 'package:neffils/ui/values_manager.dart';
import '../../widgets/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              vertical: AppSize.s16, horizontal: AppSize.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo/mainlogo.png', height: 80),
              const SizedBox(height: 16),
              Text(
                "Login for recommendation or new industry license.",
                style: getSemiBoldStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                " (सिफारिस वा नयाँ उद्योग अनुमतिपत्रको लागि लगइन गर्नुहोस् ।)",
                textAlign: TextAlign.center,
                style: getSemiBoldStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "If you don't have account please register.",
                style: getRegularStyle(
                  // fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                " (यदि तपाईंको खाता छैन भने कृपया दर्ता गर्नुहोस् ! )",
                style: getRegularStyle(),
              ),
              const SizedBox(height: 20),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

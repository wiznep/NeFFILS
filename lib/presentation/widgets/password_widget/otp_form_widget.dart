import 'package:flutter/material.dart';
import 'package:neffils/presentation/screens/auth/password_screen/reset_password_screen.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../screens/auth/login_screen.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  TextEditingController otpController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            const TextSpan(children: [
              TextSpan(
                text:
                'Enter the OTP from your email ( आफ्नो इमेलबाट आएको OTP प्रविष्ट गर्नुहोस् )',
                style: TextStyle(fontSize: 14),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: otpController,
            keyboardType: TextInputType.number,
            onChanged: (value) {},
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(6),
              fieldHeight: 50,
              fieldWidth: 50,
              activeColor: Colors.black,
              selectedColor: appColors.formsubmit,
              inactiveColor: Colors.grey.shade400,
            ),
            enableActiveFill: false, // Set true if you want background color
            animationType: AnimationType.fade,
            animationDuration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 10),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.formsubmit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              child: const Text('Verify OTP ( OTP प्रमाणित गर्नुहोस् ) ',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ResetPasswordScreen()));
              },
          ),
          const SizedBox(height: 10),
          Center(
              child:Padding(padding:
              const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.arrow_back, size: 18, color: Colors.black),
                        ),
                        const TextSpan(
                          text: ' Back to Log in',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}

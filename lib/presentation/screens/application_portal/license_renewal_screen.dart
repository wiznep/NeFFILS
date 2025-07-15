import 'package:flutter/material.dart';

class LicenseRenewalScreen extends StatelessWidget {
  const LicenseRenewalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('License Renewal'),
      ),
      body: Center(
        child: Text(
          'License Renewal Screen',
        ),
      ),
    );
  }
}
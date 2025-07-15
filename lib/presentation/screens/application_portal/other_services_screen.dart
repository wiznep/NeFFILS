import 'package:flutter/material.dart';

class OtherServicesScreen extends StatelessWidget {
  const OtherServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Services'),
      ),
      body: Center(
        child: Text(
          'Other Services Screen',
        ),
      ),
    );
  }
}
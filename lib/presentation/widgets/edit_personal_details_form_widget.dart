import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';

class EditPersonalDetailsForm extends StatefulWidget {
  const EditPersonalDetailsForm({super.key});

  @override
  State<EditPersonalDetailsForm> createState() => _EditPersonalDetailsFormState();
}

class _EditPersonalDetailsFormState extends State<EditPersonalDetailsForm> {
  final TextEditingController _fullNameController =
  TextEditingController(text: 'SANDIP BHANDARI');
  final TextEditingController _emailController =
  TextEditingController(text: 'bhandarisandip882@gmail.com');
  final TextEditingController _phoneController =
  TextEditingController(text: '9860311353');

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Full Name Field
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Full Name '),
                TextSpan(
                  text: '( पुरा नाम )',
                  style: TextStyle(color: appColors.white_black),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _buildTextField(_fullNameController),
            const SizedBox(height: 20),

            // Email Field
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Email '),
                TextSpan(
                  text: '( इमेल )',
                  style: TextStyle(color: appColors.white_black),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _buildTextField(_emailController, isEmail: true),
            const SizedBox(height: 20),

            // Phone Field
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Phone Number '),
                TextSpan(
                  text: '( फोन नम्बर )',
                  style: TextStyle(color: appColors.white_black),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _buildTextField(_phoneController, isPhone: true),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter your ${isEmail ? 'email' : isPhone ? 'phone number' : 'full name'}',
        hintStyle: TextStyle(color: appColors.white_black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: appColors.formsubmit, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: appColors.dimwhite, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (isPhone && value.length < 10) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.formsubmit,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _submitForm,
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: appColors.formsubmit),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: appColors.formsubmit),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Save logic goes here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully')),
      );
      Navigator.pop(context);
    }
  }
}
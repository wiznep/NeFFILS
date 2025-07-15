import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neffils/utils/colors/color.dart';
import '../../../../domain/models/industry/industry_shareholder.dart';
import '../../../../domain/repositories/industry/industry_view_repository.dart';

typedef ValidationCallback = void Function(bool valid);
typedef SubmitCallback = void Function();

class ShareholdersView extends StatefulWidget {
  final String industryId;
  final ValidationCallback onValidationChanged;
  final SubmitCallback onSubmitted;

  const ShareholdersView({
    Key? key,
    required this.industryId,
    required this.onValidationChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  ShareholdersViewState createState() => ShareholdersViewState();
}

class ShareholdersViewState extends State<ShareholdersView> {
  final _formKey = GlobalKey<FormState>();
  final IndustryViewRepository _repository = IndustryViewRepository();
  final ImagePicker _imagePicker = ImagePicker();

  List<Shareholder> _shareholders = [];

  final Color primaryColor = appColors.formsubmit;
  final Color errorColor = Colors.red;
  final Color cardColor = Colors.white;
  final Color textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadShareholders();
  }

  Future<void> _loadShareholders() async {
    try {
      final fetched = await _repository.fetchShareholders(widget.industryId);
      setState(() => _shareholders = fetched);
    } catch (_) {
      setState(() => _shareholders = []);
    }
    _validateAll();
  }

  void _validateAll() {
    final allValid = _shareholders.isNotEmpty && _shareholders.every((sh) => sh.isValid());
    widget.onValidationChanged(allValid);
  }

  void _onFieldChanged(int i, Shareholder updated) {
    setState(() => _shareholders[i] = updated);
    _validateAll();
  }

  Future<void> _pickImage(int i) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final size = await file.length();

        if (size <= 5 * 1024 * 1024) {
          _onFieldChanged(i, _shareholders[i].copyWith(citizenshipImagePath: pickedFile.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image size must be less than 5MB')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  void _viewImage(String? imagePath) {
    if (imagePath == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(File(imagePath)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewShareholder() {
    setState(() {
      _shareholders.add(Shareholder(nameEnglish: '', nameNepali: '', citizenshipNumber: ''));
    });
    _validateAll();
  }

  void _removeShareholder(int i) {
    setState(() => _shareholders.removeAt(i));
    _validateAll();
  }

  bool validate() {
    if (_shareholders.isEmpty) return false;
    if (!_formKey.currentState!.validate()) return false;
    if (!_shareholders.every((sh) => sh.isValid())) return false;
    return true;
  }

  Future<void> submit() async {
    if (!validate()) throw Exception('Validation failed');

    await _repository.submitShareholders(
      industryId: widget.industryId,
      shareholders: _shareholders,
    );
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(1),
      child: Form(
        key: _formKey,
        onChanged: _validateAll,
        child: Column(
          children: [
            Center(child: Text('Board of Directors', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: primaryColor))),
            const SizedBox(height: 14),
            ...List.generate(_shareholders.length, (i) {
              final s = _shareholders[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shareholder Number ${i + 1}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                        if (i > 0)
                          IconButton(
                            icon: Icon(Icons.delete, color: errorColor, size: 20),
                            onPressed: () => _removeShareholder(i),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFormField('Name in English', 'Enter name in English', s.nameEnglish, (v) => _onFieldChanged(i, s.copyWith(nameEnglish: v))),
                    const SizedBox(height: 16),
                    _buildFormField('Name in Nepali', 'Enter name in Nepali', s.nameNepali, (v) => _onFieldChanged(i, s.copyWith(nameNepali: v))),
                    const SizedBox(height: 16),
                    _buildFormField('Citizenship Number', 'Enter citizenship number', s.citizenshipNumber, (v) => _onFieldChanged(i, s.copyWith(citizenshipNumber: v))),
                    const SizedBox(height: 16),
                    Text('Citizenship File (Max 5 MB)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _pickImage(i),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload, size: 20),
                          const SizedBox(width: 8),
                          Text('Upload Citizenship Image'),
                        ],
                      ),
                    ),
                    if (s.citizenshipImagePath != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected: ${s.citizenshipImagePath!.split('/').last}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _viewImage(s.citizenshipImagePath),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 20),
                            const SizedBox(width: 8),
                            Text('View Image'),
                          ],
                        ),
                      ),
                    ],
                    if (!s.hasValidImage())
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Invalid image (missing or too large).', style: TextStyle(color: errorColor)),
                      ),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 14),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addNewShareholder,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Shareholder', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint, String initial, ValueChanged<String> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: initial,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryColor)),
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    ]);
  }
}
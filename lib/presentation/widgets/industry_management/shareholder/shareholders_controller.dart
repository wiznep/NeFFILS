import 'package:flutter/material.dart';
import 'shareholders_view.dart';

class ShareholdersController extends StatefulWidget {
  final String industryId;
  final Function(bool) onValidationChanged;
  final VoidCallback onSubmitted;

  const ShareholdersController({
    Key? key,
    required this.industryId,
    required this.onValidationChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  ShareholdersControllerState createState() => ShareholdersControllerState();
}

class ShareholdersControllerState extends State<ShareholdersController> {
  final GlobalKey<ShareholdersViewState> _shareholdersViewKey = GlobalKey<ShareholdersViewState>();

  bool validate() {
    return _shareholdersViewKey.currentState?.validate() ?? false;
  }

  Future<void> submit() async {
    final isValid = validate();
    if (!isValid) return;

    try {
      await _shareholdersViewKey.currentState!.submit();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShareholdersView(
      key: _shareholdersViewKey,
      industryId: widget.industryId,
      onValidationChanged: widget.onValidationChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// See Johannes Milke Course on making Profile page
class TextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final String errorText;
  final RegExp? regEx;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const TextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.onChanged,
    this.hintText = "",
    this.errorText = "",
    this.regEx,
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController controller;
  bool _regExMatches = true;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: _buildDecoration(context),
              maxLines: widget.maxLines,
              onChanged: _onChanged,
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
            ),
          ],
        )
      );

  void _onChanged(String text){
    if (widget.regEx != null){
      final bool match = widget.regEx!.hasMatch(text);
      if ( match != _regExMatches){
        setState(() {
          _regExMatches = !_regExMatches;
        });
      }
    }
    widget.onChanged(text);
  }

  InputDecoration _buildDecoration(BuildContext context) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.green,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      hintText: widget.hintText,
      errorText: _regExMatches? null : widget.errorText,
      errorStyle: const TextStyle(color: Colors.red),
      suffixIcon: _regExMatches? null : const Icon(Icons.warning_amber),
    );
  }
}
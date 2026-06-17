import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AcademicTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isRequired;
  final int maxLines;

  const AcademicTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isRequired = false,
    this.maxLines = 1,
  });

  @override
  State<AcademicTextFormField> createState() => _AcademicTextFormFieldState();
}

class _AcademicTextFormFieldState extends State<AcademicTextFormField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController {
    // If the provided controller is unusable (disposed), fall back to an internal one.
    try {
      // Accessing `.text` will throw if the controller was disposed.
      final _ = widget.controller.text;
      return widget.controller;
    } catch (_) {
      _internalController ??= TextEditingController();
      return _internalController!;
    }
  }

  @override
  void didUpdateWidget(covariant AcademicTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If an internal controller exists but the new external controller is valid,
    // transfer text and dispose the internal one.
    if (_internalController != null) {
      try {
        final _ = widget.controller.text;
        // external controller is usable now, transfer value
        widget.controller.text = _internalController!.text;
        _internalController!.dispose();
        _internalController = null;
      } catch (_) {
        // external still unusable — keep internal controller
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerToUse = _effectiveController;

    return TextFormField(
      controller: controllerToUse,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: AppTheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppTheme.background,
      ),
      validator: widget.isRequired
          ? (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null
          : null,
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'academic_major_dropdown.dart';

class AcademicFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedMajor;
  final ValueChanged<String?> onMajorChanged;

  const AcademicFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedMajor,
    required this.onMajorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن المادة...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: AcademicMajorDropdown(
              value: selectedMajor,
              onChanged: onMajorChanged,
              includeAllOption: true,
            ),
          ),
        ],
      ),
    );
  }
}

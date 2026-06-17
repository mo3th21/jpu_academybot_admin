import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AcademicMajorDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final bool includeAllOption;
  final String allLabel;

  const AcademicMajorDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.includeAllOption = false,
    this.allLabel = 'الكل',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, color: AppTheme.primary),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                if (includeAllOption)
                  DropdownMenuItem<String>(
                    value: 'All',
                    child: Text(allLabel),
                  ),
                const DropdownMenuItem<String>(value: 'أمن سيبراني', child: Text('أمن سيبراني')),
                const DropdownMenuItem<String>(value: 'علم حاسوب', child: Text('علم حاسوب')),
                const DropdownMenuItem<String>(value: 'شبكات الحاسوب', child: Text('شبكات الحاسوب')),
                const DropdownMenuItem<String>(value: 'مواد مشتركة', child: Text('مواد مشتركة')),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

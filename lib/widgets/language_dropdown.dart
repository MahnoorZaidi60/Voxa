import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LanguageDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final Color? textColor;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: textColor ?? Colors.grey),
          isDense: true,
          dropdownColor: Theme.of(context).cardColor,
          style: TextStyle(
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
          items: AppConstants.languages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
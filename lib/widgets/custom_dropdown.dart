import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';


class CustomDropdown extends StatelessWidget {
  final String hint;
  final Map<String, String> items;
  final String? selectedItemId;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final bool showSearch;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    this.selectedItemId,
    this.onChanged,
    this.enabled = true,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate adaptive height
    const itemHeight = 48.0; // Height per item
    final searchBoxHeight = showSearch ? 56.0 : 0.0; // Search box height if enabled
    const padding = 16.0; // Top and bottom padding
    final calculatedHeight = (items.length * itemHeight) + searchBoxHeight + padding;
    final maxAllowedHeight = MediaQuery.of(context).size.height / 2;

    return DropdownSearch<String>(
      enabled: enabled,
      popupProps: PopupProps.menu(
        showSearchBox: showSearch,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: Icon(Icons.search, color: AppColors.placeholder),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.textField,
          ),
        ),
        showSelectedItems: true,
        constraints: BoxConstraints(
          // Only apply maxHeight if calculated height exceeds maximum allowed height
          maxHeight: calculatedHeight > maxAllowedHeight ? maxAllowedHeight : calculatedHeight,
        ),
      ),
      items: items.values.toList(),
      selectedItem: selectedItemId != null ? items[selectedItemId] : null,
      onChanged: (selectedName) {
        final selectedId = items.keys.firstWhere(
              (id) => items[id] == selectedName,
          orElse: () => '',
        );
        onChanged?.call(selectedId);
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          filled: true,
          fillColor: AppColors.textField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
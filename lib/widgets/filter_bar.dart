import 'package:flutter/material.dart';
import '../models/recipe.dart';

/// A horizontal filter bar shown above the recipe list.
class FilterBar extends StatelessWidget {
  final List<String> cuisines;
  final String? selectedCuisine;
  final Difficulty? selectedDifficulty;
  final RecipeStatus? selectedStatus;
  final int? maxPrepTime;
  final bool hasActiveFilters;
  final void Function({
    String? cuisine,
    Difficulty? difficulty,
    RecipeStatus? status,
    int? maxPrepTime,
  }) onFilterChanged;
  final VoidCallback onClear;

  const FilterBar({
    super.key,
    required this.cuisines,
    this.selectedCuisine,
    this.selectedDifficulty,
    this.selectedStatus,
    this.maxPrepTime,
    required this.hasActiveFilters,
    required this.onFilterChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Cuisine dropdown
          _dropdown<String>(
            label: 'Cuisine',
            value: selectedCuisine,
            items: cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => onFilterChanged(cuisine: v),
          ),
          const SizedBox(width: 8),
          // Difficulty dropdown
          _dropdown<Difficulty>(
            label: 'Difficulty',
            value: selectedDifficulty,
            items: Difficulty.values
                .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                .toList(),
            onChanged: (v) => onFilterChanged(difficulty: v),
          ),
          const SizedBox(width: 8),
          // Status dropdown
          _dropdown<RecipeStatus>(
            label: 'Status',
            value: selectedStatus,
            items: RecipeStatus.values
                .where((s) => s != RecipeStatus.none)
                .map((s) => DropdownMenuItem(
                    value: s, child: Text('${s.icon} ${s.label}')))
                .toList(),
            onChanged: (v) => onFilterChanged(status: v),
          ),
          const SizedBox(width: 8),
          // Prep time dropdown
          _dropdown<int>(
            label: 'Max Time',
            value: maxPrepTime,
            items: [15, 30, 45, 60, 90, 120]
                .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                .toList(),
            onChanged: (v) => onFilterChanged(maxPrepTime: v),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              onPressed: onClear,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          hint: Text(label, style: const TextStyle(fontSize: 13)),
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}

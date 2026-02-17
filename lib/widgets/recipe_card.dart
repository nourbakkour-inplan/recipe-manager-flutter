import 'package:flutter/material.dart';
import '../models/recipe.dart';

/// A card widget displaying a recipe summary in the list view.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onDelete,
  });

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  if (recipe.status != RecipeStatus.none)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(recipe.status.icon, style: const TextStyle(fontSize: 16)),
                    ),
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Metadata chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _chip(recipe.cuisineType, Icons.public, cs.primaryContainer,
                      cs.onPrimaryContainer),
                  _chip('${recipe.prepTime} min', Icons.timer_outlined,
                      cs.secondaryContainer, cs.onSecondaryContainer),
                  _chip(
                    recipe.difficulty.label,
                    Icons.signal_cellular_alt,
                    _difficultyColor(recipe.difficulty).withOpacity(0.15),
                    _difficultyColor(recipe.difficulty),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ingredients preview
              Text(
                recipe.ingredients.take(4).join(', ') +
                    (recipe.ingredients.length > 4 ? '...' : ''),
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Tags
              if (recipe.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: recipe.tags
                      .take(4)
                      .map((t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}

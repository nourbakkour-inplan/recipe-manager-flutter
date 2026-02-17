import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/ai_service.dart';

/// Dialog showing AI-suggested similar recipes.
class SimilarRecipesDialog extends StatelessWidget {
  final List<ScoredRecipe> similar;

  const SimilarRecipesDialog({super.key, required this.similar});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Similar Recipes'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: similar.isEmpty
            ? const Text('No similar recipes found.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: similar.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final sr = similar[i];
                  return ListTile(
                    title: Text(sr.recipe.name),
                    subtitle: Text(
                        '${sr.recipe.cuisineType} · ${sr.recipe.prepTime} min'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(sr.percentLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          )),
                    ),
                    dense: true,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Dialog showing AI-suggested missing ingredients.
class MissingIngredientsDialog extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onAdd;

  const MissingIngredientsDialog({
    super.key,
    required this.suggestions,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          const Text('Suggested Ingredients'),
        ],
      ),
      content: SizedBox(
        width: 350,
        child: suggestions.isEmpty
            ? const Text('No suggestions — try adding more ingredients first.')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map((s) => ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: Text(s),
                          onPressed: () {
                            onAdd(s);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

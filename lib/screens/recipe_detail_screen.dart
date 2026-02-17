import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ai_suggestions_dialog.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final recipeProv = context.watch<RecipeProvider>();
    final userId = context.read<AuthProvider>().currentUser!.id;
    final recipe = recipeProv.recipes.cast<Recipe?>().firstWhere(
          (r) => r!.id == recipeId,
          orElse: () => null,
        );

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RecipeFormScreen(recipe: recipe)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status buttons ───────────────────────────────────────
                _StatusRow(recipe: recipe),
                const SizedBox(height: 16),

                // ── Metadata ─────────────────────────────────────────────
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _metaChip(Icons.public, recipe.cuisineType, context),
                    _metaChip(Icons.timer_outlined, '${recipe.prepTime} min',
                        context),
                    _metaChip(Icons.signal_cellular_alt,
                        recipe.difficulty.label, context),
                  ],
                ),
                if (recipe.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recipe.tags
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                ],
                const Divider(height: 32),

                // ── Ingredients ──────────────────────────────────────────
                Text('Ingredients',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(ing)),
                        ],
                      ),
                    )),
                const Divider(height: 32),

                // ── Instructions ─────────────────────────────────────────
                Text('Instructions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(recipe.instructions,
                    style: const TextStyle(height: 1.6)),
                const Divider(height: 32),

                // ── AI Actions ───────────────────────────────────────────
                Text('AI Tools',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Find Similar Recipes'),
                      onPressed: () {
                        final similar = recipeProv.findSimilar(recipe);
                        showDialog(
                          context: context,
                          builder: (_) =>
                              SimilarRecipesDialog(similar: similar),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('Suggest Missing Ingredients'),
                      onPressed: () {
                        final suggestions =
                            recipeProv.suggestMissing(recipe.ingredients);
                        showDialog(
                          context: context,
                          builder: (_) => MissingIngredientsDialog(
                            suggestions: suggestions,
                            onAdd: (_) {}, // read-only in detail view
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

/// Row of toggleable status buttons (Favorite / To Try / Made Before).
class _StatusRow extends StatelessWidget {
  final Recipe recipe;
  const _StatusRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<RecipeProvider>();
    return Row(
      children: [
        _statusBtn(context, prov, RecipeStatus.favorite, Icons.favorite,
            Icons.favorite_border, Colors.red),
        const SizedBox(width: 8),
        _statusBtn(context, prov, RecipeStatus.toTry, Icons.push_pin,
            Icons.push_pin_outlined, Colors.amber.shade700),
        const SizedBox(width: 8),
        _statusBtn(context, prov, RecipeStatus.madeBefore,
            Icons.check_circle, Icons.check_circle_outline, Colors.green),
      ],
    );
  }

  Widget _statusBtn(BuildContext context, RecipeProvider prov,
      RecipeStatus status, IconData active, IconData inactive, Color color) {
    final isActive = recipe.status == status;
    return OutlinedButton.icon(
      icon: Icon(isActive ? active : inactive,
          color: isActive ? color : null, size: 18),
      label: Text(status.label),
      style: OutlinedButton.styleFrom(
        side: isActive ? BorderSide(color: color, width: 1.5) : null,
      ),
      onPressed: () => prov.toggleStatus(recipe, status),
    );
  }
}

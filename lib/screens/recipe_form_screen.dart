import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ai_suggestions_dialog.dart';

/// Create or edit a recipe.
class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe; // null = create mode
  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _instructionsCtrl;
  late final TextEditingController _cuisineCtrl;
  late final TextEditingController _prepTimeCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _ingredientCtrl;

  late Difficulty _difficulty;
  late List<String> _ingredients;
  late List<String> _tags;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _instructionsCtrl = TextEditingController(text: r?.instructions ?? '');
    _cuisineCtrl = TextEditingController(text: r?.cuisineType ?? '');
    _prepTimeCtrl = TextEditingController(text: r?.prepTime.toString() ?? '30');
    _tagCtrl = TextEditingController();
    _ingredientCtrl = TextEditingController();
    _difficulty = r?.difficulty ?? Difficulty.medium;
    _ingredients = List<String>.from(r?.ingredients ?? []);
    _tags = List<String>.from(r?.tags ?? []);
  }

  void _addIngredient() {
    final text = _ingredientCtrl.text.trim();
    if (text.isNotEmpty && !_ingredients.contains(text)) {
      setState(() => _ingredients.add(text));
      _ingredientCtrl.clear();
    }
  }

  void _addTag() {
    final text = _tagCtrl.text.trim().toLowerCase();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() => _tags.add(text));
      _tagCtrl.clear();
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser!.id;
    final prov = context.read<RecipeProvider>();
    final prepTime = int.tryParse(_prepTimeCtrl.text) ?? 30;
    final cuisine = _cuisineCtrl.text.trim().isEmpty
        ? 'Other'
        : _cuisineCtrl.text.trim();

    if (_isEditing) {
      final updated = widget.recipe!.copyWith(
        name: _nameCtrl.text.trim(),
        ingredients: _ingredients,
        instructions: _instructionsCtrl.text.trim(),
        cuisineType: cuisine,
        prepTime: prepTime,
        difficulty: _difficulty,
        tags: _tags,
      );
      await prov.updateRecipe(updated);
    } else {
      await prov.createRecipe(
        userId: userId,
        name: _nameCtrl.text.trim(),
        ingredients: _ingredients,
        instructions: _instructionsCtrl.text.trim(),
        cuisineType: cuisine,
        prepTime: prepTime,
        difficulty: _difficulty,
        tags: _tags,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  // ── AI Helpers ─────────────────────────────────────────────────────────

  void _autoCuisine() {
    final detected = context.read<RecipeProvider>().detectCuisine(
          _nameCtrl.text,
          _ingredients,
        );
    setState(() => _cuisineCtrl.text = detected);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI detected cuisine: $detected')),
    );
  }

  void _suggestMissing() {
    final suggestions =
        context.read<RecipeProvider>().suggestMissing(_ingredients);
    showDialog(
      context: context,
      builder: (_) => MissingIngredientsDialog(
        suggestions: suggestions,
        onAdd: (item) {
          setState(() {
            if (!_ingredients.contains(item)) _ingredients.add(item);
          });
        },
      ),
    );
  }

  void _autoTags() {
    final prepTime = int.tryParse(_prepTimeCtrl.text) ?? 30;
    final suggested = context.read<RecipeProvider>().suggestTags(
          _nameCtrl.text,
          _ingredients,
          prepTime,
          _difficulty,
        );
    setState(() {
      for (final t in suggested) {
        if (!_tags.contains(t)) _tags.add(t);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI added ${suggested.length} tag(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name ───────────────────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Ingredients ────────────────────────────────────────
                  Text('Ingredients *',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add ingredient...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: _addIngredient,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.lightbulb_outline),
                        tooltip: 'AI: Suggest missing ingredients',
                        onPressed: _suggestMissing,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _ingredients
                        .map((ing) => Chip(
                              label: Text(ing),
                              onDeleted: () =>
                                  setState(() => _ingredients.remove(ing)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Instructions ───────────────────────────────────────
                  TextFormField(
                    controller: _instructionsCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Instructions *',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Cuisine + AI button ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cuisineCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cuisine Type',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Auto-detect'),
                        onPressed: _autoCuisine,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Prep time & Difficulty ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prep Time (min)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (int.tryParse(v) == null) return 'Enter a number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Difficulty>(
                          value: _difficulty,
                          decoration: const InputDecoration(
                            labelText: 'Difficulty',
                            border: OutlineInputBorder(),
                          ),
                          items: Difficulty.values
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text(d.label)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _difficulty = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tags ───────────────────────────────────────────────
                  Text('Tags', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add tag...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                      const SizedBox(width: 4),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Auto-tag'),
                        onPressed: _autoTags,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags
                        .map((t) => Chip(
                              label: Text(t),
                              onDeleted: () =>
                                  setState(() => _tags.remove(t)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructionsCtrl.dispose();
    _cuisineCtrl.dispose();
    _prepTimeCtrl.dispose();
    _tagCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
  }
}

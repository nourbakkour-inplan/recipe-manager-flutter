import 'dart:math';
import '../models/recipe.dart';

/// Local AI service — no external API needed.
/// Uses keyword matching, ingredient co-occurrence, and Jaccard similarity.
class AIService {
  // ── Cuisine Detection ──────────────────────────────────────────────────
  // Keyword → cuisine mapping for auto-categorization.
  static const _cuisineKeywords = <String, List<String>>{
    'Italian': [
      'pasta', 'pizza', 'risotto', 'mozzarella', 'parmesan', 'basil',
      'oregano', 'marinara', 'lasagna', 'pesto', 'prosciutto', 'tiramisu',
      'gnocchi', 'bruschetta', 'focaccia', 'ravioli', 'bolognese',
    ],
    'Mexican': [
      'taco', 'tortilla', 'salsa', 'guacamole', 'jalapeño', 'cilantro',
      'enchilada', 'burrito', 'quesadilla', 'chipotle', 'cumin', 'nacho',
      'churro', 'fajita', 'tamale', 'mole',
    ],
    'Chinese': [
      'soy sauce', 'wok', 'tofu', 'noodle', 'dumpling', 'ginger',
      'sesame', 'bok choy', 'dim sum', 'stir fry', 'hoisin', 'szechuan',
      'kung pao', 'chow mein', 'spring roll', 'five spice',
    ],
    'Japanese': [
      'sushi', 'ramen', 'teriyaki', 'wasabi', 'miso', 'sake', 'tempura',
      'edamame', 'udon', 'soba', 'dashi', 'matcha', 'katsu', 'onigiri',
    ],
    'Indian': [
      'curry', 'turmeric', 'garam masala', 'naan', 'paneer', 'cardamom',
      'biryani', 'tandoori', 'dal', 'chutney', 'masala', 'samosa',
      'tikka', 'basmati', 'ghee', 'korma', 'vindaloo',
    ],
    'Thai': [
      'pad thai', 'coconut milk', 'lemongrass', 'fish sauce', 'thai basil',
      'green curry', 'red curry', 'galangal', 'tom yum', 'satay',
      'sticky rice', 'kaffir lime',
    ],
    'French': [
      'croissant', 'baguette', 'beurre', 'crème', 'soufflé', 'ratatouille',
      'quiche', 'crêpe', 'béchamel', 'coq au vin', 'brioche', 'gratin',
      'bouillabaisse', 'tarte',
    ],
    'Mediterranean': [
      'olive oil', 'feta', 'hummus', 'tahini', 'pita', 'couscous',
      'chickpea', 'za\'atar', 'lentil', 'eggplant', 'lamb', 'yogurt',
    ],
    'American': [
      'burger', 'barbecue', 'bbq', 'cornbread', 'mac and cheese',
      'coleslaw', 'hot dog', 'brisket', 'pulled pork', 'pancake', 'waffle',
    ],
    'Korean': [
      'kimchi', 'gochujang', 'bulgogi', 'bibimbap', 'ssamjang', 'japchae',
      'tteokbokki', 'banchan', 'doenjang', 'korean bbq',
    ],
  };

  /// Auto-detect cuisine type from recipe name and ingredients.
  String detectCuisine(String name, List<String> ingredients) {
    final text =
        '${name.toLowerCase()} ${ingredients.join(' ').toLowerCase()}';
    final scores = <String, int>{};

    for (final entry in _cuisineKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (text.contains(keyword.toLowerCase())) score++;
      }
      if (score > 0) scores[entry.key] = score;
    }

    if (scores.isEmpty) return 'Other';
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  // ── Similar Recipes ────────────────────────────────────────────────────

  /// Find recipes similar to [recipe] from [allRecipes] using Jaccard
  /// similarity on normalised ingredient sets.
  List<ScoredRecipe> findSimilar(Recipe recipe, List<Recipe> allRecipes,
      {int limit = 5}) {
    final baseSet = _normalise(recipe.ingredients);
    final scored = <ScoredRecipe>[];

    for (final other in allRecipes) {
      if (other.id == recipe.id) continue;
      final otherSet = _normalise(other.ingredients);
      final intersection = baseSet.intersection(otherSet).length;
      final union = baseSet.union(otherSet).length;
      if (union == 0) continue;
      final score = intersection / union;
      if (score > 0.1) scored.add(ScoredRecipe(other, score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  Set<String> _normalise(List<String> items) =>
      items.map((e) => e.toLowerCase().trim()).toSet();

  // ── Missing Ingredient Suggestions ─────────────────────────────────────
  // Common ingredient groups — if you have some, the AI suggests the rest.
  static const _ingredientGroups = <List<String>>[
    ['flour', 'sugar', 'butter', 'eggs', 'baking powder', 'vanilla extract'],
    ['pasta', 'olive oil', 'garlic', 'parmesan', 'salt', 'pepper'],
    ['chicken', 'garlic', 'onion', 'salt', 'pepper', 'olive oil'],
    ['rice', 'soy sauce', 'garlic', 'ginger', 'sesame oil', 'green onion'],
    ['tortilla', 'chicken', 'cheese', 'salsa', 'sour cream', 'lettuce'],
    ['ground beef', 'onion', 'garlic', 'tomato sauce', 'salt', 'pepper'],
    ['salmon', 'lemon', 'dill', 'olive oil', 'salt', 'pepper'],
    ['potatoes', 'butter', 'milk', 'salt', 'pepper', 'chives'],
    ['bread', 'butter', 'cheese', 'tomato', 'lettuce', 'mayo'],
    ['tofu', 'soy sauce', 'sesame oil', 'garlic', 'ginger', 'rice vinegar'],
    ['eggs', 'milk', 'cheese', 'salt', 'pepper', 'butter'],
    ['lentils', 'onion', 'garlic', 'cumin', 'tomato', 'salt'],
    ['shrimp', 'garlic', 'butter', 'lemon', 'parsley', 'white wine'],
    ['coconut milk', 'curry paste', 'chicken', 'basil', 'fish sauce', 'lime'],
    ['chickpeas', 'tahini', 'lemon', 'garlic', 'olive oil', 'cumin'],
  ];

  /// Suggest ingredients the user might be missing based on what they have.
  List<String> suggestMissing(List<String> current) {
    if (current.isEmpty) return [];
    final normalised = _normalise(current);
    final suggestions = <String, int>{};

    for (final group in _ingredientGroups) {
      final groupSet = group.map((e) => e.toLowerCase()).toSet();
      final overlap = normalised.intersection(groupSet);
      if (overlap.length >= 2) {
        for (final item in groupSet.difference(normalised)) {
          suggestions[item] = (suggestions[item] ?? 0) + 1;
        }
      }
    }

    final sorted = suggestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(8).map((e) => e.key).toList();
  }

  // ── Tag Suggestions ────────────────────────────────────────────────────

  /// Auto-suggest tags based on recipe content.
  List<String> suggestTags(String name, List<String> ingredients, int prepTime,
      Difficulty difficulty) {
    final tags = <String>{};
    final text =
        '${name.toLowerCase()} ${ingredients.join(' ').toLowerCase()}';

    // Diet tags
    final meatKeywords = [
      'chicken', 'beef', 'pork', 'lamb', 'fish', 'salmon', 'shrimp',
      'bacon', 'sausage', 'turkey', 'duck', 'steak', 'ground beef',
    ];
    final dairyKeywords = ['cheese', 'milk', 'cream', 'butter', 'yogurt'];
    final hasMeat = meatKeywords.any((k) => text.contains(k));
    final hasDairy = dairyKeywords.any((k) => text.contains(k));

    if (!hasMeat && !hasDairy) tags.add('vegan');
    else if (!hasMeat) tags.add('vegetarian');

    // Meal type
    if (text.contains('breakfast') ||
        text.contains('pancake') ||
        text.contains('waffle') ||
        text.contains('omelette')) {
      tags.add('breakfast');
    }
    if (text.contains('dessert') ||
        text.contains('cake') ||
        text.contains('cookie') ||
        text.contains('brownie') ||
        text.contains('pie')) {
      tags.add('dessert');
    }
    if (text.contains('soup') || text.contains('stew') || text.contains('broth')) {
      tags.add('soup');
    }
    if (text.contains('salad')) tags.add('salad');
    if (text.contains('sandwich') || text.contains('wrap')) tags.add('sandwich');
    if (text.contains('grill') || text.contains('bbq') || text.contains('barbecue')) {
      tags.add('grilled');
    }

    // Speed tags
    if (prepTime <= 15) tags.add('quick');
    if (prepTime <= 30) tags.add('under-30-min');
    if (prepTime >= 60) tags.add('slow-cook');

    // Difficulty
    if (difficulty == Difficulty.easy) tags.add('beginner-friendly');

    // Healthy
    if (text.contains('salad') ||
        text.contains('quinoa') ||
        text.contains('kale') ||
        text.contains('spinach') ||
        text.contains('avocado')) {
      tags.add('healthy');
    }

    return tags.toList()..sort();
  }
}

/// A recipe paired with a similarity score.
class ScoredRecipe {
  final Recipe recipe;
  final double score;
  ScoredRecipe(this.recipe, this.score);

  String get percentLabel => '${(score * 100).round()}%';
}

import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import 'storage_service.dart';

/// CRUD operations for recipes, scoped to the current user.
class RecipeService {
  final StorageService _storage;
  RecipeService(this._storage);

  List<Recipe> getUserRecipes(String userId) =>
      _storage.getRecipesForUser(userId)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  Recipe? getRecipe(String id) => _storage.getRecipeById(id);

  Future<Recipe> createRecipe({
    required String userId,
    required String name,
    required List<String> ingredients,
    required String instructions,
    String cuisineType = 'Other',
    int prepTime = 30,
    Difficulty difficulty = Difficulty.medium,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final recipe = Recipe(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      cuisineType: cuisineType,
      prepTime: prepTime,
      difficulty: difficulty,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    await _storage.saveRecipe(recipe);
    return recipe;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _storage.saveRecipe(recipe);
  }

  Future<void> deleteRecipe(String id) async {
    await _storage.deleteRecipe(id);
  }

  /// Searches and filters recipes for a user.
  List<Recipe> search(
    String userId, {
    String query = '',
    String? cuisineType,
    String? ingredient,
    String? tag,
    int? maxPrepTime,
    Difficulty? difficulty,
    RecipeStatus? status,
  }) {
    var results = getUserRecipes(userId);
    final q = query.toLowerCase().trim();

    if (q.isNotEmpty) {
      results = results
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.ingredients.any((i) => i.toLowerCase().contains(q)))
          .toList();
    }
    if (cuisineType != null && cuisineType.isNotEmpty) {
      results = results
          .where(
              (r) => r.cuisineType.toLowerCase() == cuisineType.toLowerCase())
          .toList();
    }
    if (ingredient != null && ingredient.isNotEmpty) {
      final ing = ingredient.toLowerCase();
      results = results
          .where((r) => r.ingredients.any((i) => i.toLowerCase().contains(ing)))
          .toList();
    }
    if (tag != null && tag.isNotEmpty) {
      final t = tag.toLowerCase();
      results = results
          .where((r) => r.tags.any((rt) => rt.toLowerCase().contains(t)))
          .toList();
    }
    if (maxPrepTime != null) {
      results = results.where((r) => r.prepTime <= maxPrepTime).toList();
    }
    if (difficulty != null) {
      results = results.where((r) => r.difficulty == difficulty).toList();
    }
    if (status != null && status != RecipeStatus.none) {
      results = results.where((r) => r.status == status).toList();
    }
    return results;
  }
}

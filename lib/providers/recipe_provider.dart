import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

/// Provides recipe state, search/filter, and AI features to the widget tree.
class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService;
  final AIService _aiService = AIService();
  final StorageService _storage;

  List<Recipe> _recipes = [];
  String _searchQuery = '';
  String? _filterCuisine;
  String? _filterIngredient;
  String? _filterTag;
  int? _filterMaxPrepTime;
  Difficulty? _filterDifficulty;
  RecipeStatus? _filterStatus;

  RecipeProvider(this._storage) : _recipeService = RecipeService(_storage);

  // ── Getters ────────────────────────────────────────────────────────────

  List<Recipe> get recipes => _recipes;
  String get searchQuery => _searchQuery;
  String? get filterCuisine => _filterCuisine;
  AIService get aiService => _aiService;

  bool get hasActiveFilters =>
      _filterCuisine != null ||
      _filterIngredient != null ||
      _filterTag != null ||
      _filterMaxPrepTime != null ||
      _filterDifficulty != null ||
      _filterStatus != null;

  /// All distinct cuisine types across the current user's recipes.
  List<String> get availableCuisines {
    final cuisines =
        _recipes.map((r) => r.cuisineType).toSet().toList()..sort();
    return cuisines;
  }

  // ── Load & Refresh ─────────────────────────────────────────────────────

  void loadRecipes(String userId) {
    _recipes = _recipeService.search(
      userId,
      query: _searchQuery,
      cuisineType: _filterCuisine,
      ingredient: _filterIngredient,
      tag: _filterTag,
      maxPrepTime: _filterMaxPrepTime,
      difficulty: _filterDifficulty,
      status: _filterStatus,
    );
    notifyListeners();
  }

  // ── Search & Filter ────────────────────────────────────────────────────

  void setSearchQuery(String query, String userId) {
    _searchQuery = query;
    loadRecipes(userId);
  }

  void setFilters({
    String? cuisine,
    String? ingredient,
    String? tag,
    int? maxPrepTime,
    Difficulty? difficulty,
    RecipeStatus? status,
    required String userId,
  }) {
    _filterCuisine = cuisine;
    _filterIngredient = ingredient;
    _filterTag = tag;
    _filterMaxPrepTime = maxPrepTime;
    _filterDifficulty = difficulty;
    _filterStatus = status;
    loadRecipes(userId);
  }

  void clearFilters(String userId) {
    _filterCuisine = null;
    _filterIngredient = null;
    _filterTag = null;
    _filterMaxPrepTime = null;
    _filterDifficulty = null;
    _filterStatus = null;
    _searchQuery = '';
    loadRecipes(userId);
  }

  // ── CRUD ───────────────────────────────────────────────────────────────

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
    final recipe = await _recipeService.createRecipe(
      userId: userId,
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      cuisineType: cuisineType,
      prepTime: prepTime,
      difficulty: difficulty,
      tags: tags,
    );
    loadRecipes(userId);
    return recipe;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeService.updateRecipe(recipe);
    loadRecipes(recipe.userId);
  }

  Future<void> deleteRecipe(String id, String userId) async {
    await _recipeService.deleteRecipe(id);
    loadRecipes(userId);
  }

  Future<void> toggleStatus(Recipe recipe, RecipeStatus status) async {
    final updated = recipe.copyWith(
      status: recipe.status == status ? RecipeStatus.none : status,
    );
    await _recipeService.updateRecipe(updated);
    loadRecipes(recipe.userId);
  }

  // ── AI Features ────────────────────────────────────────────────────────

  String detectCuisine(String name, List<String> ingredients) =>
      _aiService.detectCuisine(name, ingredients);

  List<ScoredRecipe> findSimilar(Recipe recipe) =>
      _aiService.findSimilar(recipe, _storage.getAllRecipes());

  List<String> suggestMissing(List<String> ingredients) =>
      _aiService.suggestMissing(ingredients);

  List<String> suggestTags(
          String name, List<String> ingredients, int prepTime, Difficulty d) =>
      _aiService.suggestTags(name, ingredients, prepTime, d);
}

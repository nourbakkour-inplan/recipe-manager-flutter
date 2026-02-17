import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/recipe.dart';

/// Manages Hive boxes for persistent local storage (works on web).
class StorageService {
  static const _usersBox = 'users';
  static const _recipesBox = 'recipes';
  static const _sessionBox = 'session';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(RecipeAdapter());
    await Hive.openBox<User>(_usersBox);
    await Hive.openBox<Recipe>(_recipesBox);
    await Hive.openBox(_sessionBox);
  }

  // ── Users ──────────────────────────────────────────────────────────────

  Box<User> get usersBox => Hive.box<User>(_usersBox);

  Future<void> saveUser(User user) => usersBox.put(user.id, user);

  User? getUserByUsername(String username) {
    try {
      return usersBox.values.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  User? getUserById(String id) => usersBox.get(id);

  // ── Session ────────────────────────────────────────────────────────────

  Box get sessionBox => Hive.box(_sessionBox);

  Future<void> saveSession(String userId) =>
      sessionBox.put('currentUserId', userId);

  String? getSession() => sessionBox.get('currentUserId') as String?;

  Future<void> clearSession() => sessionBox.delete('currentUserId');

  // ── Recipes ────────────────────────────────────────────────────────────

  Box<Recipe> get recipesBox => Hive.box<Recipe>(_recipesBox);

  List<Recipe> getRecipesForUser(String userId) =>
      recipesBox.values.where((r) => r.userId == userId).toList();

  Future<void> saveRecipe(Recipe recipe) => recipesBox.put(recipe.id, recipe);

  Future<void> deleteRecipe(String id) => recipesBox.delete(id);

  Recipe? getRecipeById(String id) => recipesBox.get(id);

  List<Recipe> getAllRecipes() => recipesBox.values.toList();
}

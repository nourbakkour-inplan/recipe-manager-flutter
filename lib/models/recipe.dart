import 'package:hive/hive.dart';

/// Difficulty levels for recipes.
enum Difficulty { easy, medium, hard }

/// Status tags a user can apply to a recipe.
enum RecipeStatus { none, favorite, toTry, madeBefore }

/// Recipe model stored in Hive local database.
class Recipe extends HiveObject {
  String id;
  String userId;
  String name;
  List<String> ingredients;
  String instructions;
  String cuisineType;
  int prepTime; // in minutes
  Difficulty difficulty;
  List<String> tags;
  RecipeStatus status;
  DateTime createdAt;
  DateTime updatedAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.cuisineType = 'Other',
    this.prepTime = 30,
    this.difficulty = Difficulty.medium,
    this.tags = const [],
    this.status = RecipeStatus.none,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'ingredients': ingredients,
        'instructions': instructions,
        'cuisineType': cuisineType,
        'prepTime': prepTime,
        'difficulty': difficulty.index,
        'tags': tags,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Recipe.fromMap(Map<dynamic, dynamic> map) => Recipe(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        ingredients: List<String>.from(map['ingredients'] as List),
        instructions: map['instructions'] as String,
        cuisineType: map['cuisineType'] as String? ?? 'Other',
        prepTime: map['prepTime'] as int? ?? 30,
        difficulty: Difficulty.values[map['difficulty'] as int? ?? 1],
        tags: List<String>.from(map['tags'] as List? ?? []),
        status: RecipeStatus.values[map['status'] as int? ?? 0],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Recipe copyWith({
    String? name,
    List<String>? ingredients,
    String? instructions,
    String? cuisineType,
    int? prepTime,
    Difficulty? difficulty,
    List<String>? tags,
    RecipeStatus? status,
  }) =>
      Recipe(
        id: id,
        userId: userId,
        name: name ?? this.name,
        ingredients: ingredients ?? this.ingredients,
        instructions: instructions ?? this.instructions,
        cuisineType: cuisineType ?? this.cuisineType,
        prepTime: prepTime ?? this.prepTime,
        difficulty: difficulty ?? this.difficulty,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 1;

  @override
  Recipe read(BinaryReader reader) => Recipe.fromMap(reader.readMap());

  @override
  void write(BinaryWriter writer, Recipe obj) => writer.writeMap(obj.toMap());
}

// Helper extensions for display strings.
extension DifficultyExt on Difficulty {
  String get label => ['Easy', 'Medium', 'Hard'][index];
}

extension RecipeStatusExt on RecipeStatus {
  String get label => ['None', 'Favorite', 'To Try', 'Made Before'][index];
  String get icon => ['', '❤️', '📌', '✅'][index];
}

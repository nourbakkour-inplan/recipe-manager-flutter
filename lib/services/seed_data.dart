import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import 'storage_service.dart';
import 'auth_service.dart';

/// Seeds the database with sample users and recipes for testing.
class SeedData {
  static Future<void> seed(StorageService storage) async {
    // Only seed if no users exist yet.
    if (storage.usersBox.isNotEmpty) return;

    final auth = AuthService(storage);
    const uuid = Uuid();

    // ── Sample users ─────────────────────────────────────────────────────
    auth.register('alice', 'pass1234');
    auth.register('bob', 'pass1234');

    final alice = storage.getUserByUsername('alice')!;
    final bob = storage.getUserByUsername('bob')!;
    storage.clearSession(); // don't auto-login after seeding

    final now = DateTime.now();

    // ── Alice's recipes ──────────────────────────────────────────────────
    final aliceRecipes = <Recipe>[
      Recipe(
        id: uuid.v4(),
        userId: alice.id,
        name: 'Classic Margherita Pizza',
        ingredients: [
          'pizza dough', 'tomato sauce', 'fresh mozzarella', 'basil',
          'olive oil', 'salt',
        ],
        instructions:
            '1. Preheat oven to 475°F (245°C).\n'
            '2. Roll out dough on a floured surface.\n'
            '3. Spread tomato sauce evenly.\n'
            '4. Add torn mozzarella and basil leaves.\n'
            '5. Drizzle with olive oil, season with salt.\n'
            '6. Bake for 12-15 minutes until crust is golden.',
        cuisineType: 'Italian',
        prepTime: 25,
        difficulty: Difficulty.easy,
        tags: ['vegetarian', 'classic', 'under-30-min'],
        status: RecipeStatus.favorite,
        createdAt: now.subtract(Duration(days: 10)),
        updatedAt: now.subtract(Duration(days: 10)),
      ),
      Recipe(
        id: uuid.v4(),
        userId: alice.id,
        name: 'Chicken Tikka Masala',
        ingredients: [
          'chicken breast', 'yogurt', 'garam masala', 'turmeric', 'cumin',
          'tomato sauce', 'cream', 'garlic', 'ginger', 'onion', 'cilantro',
          'basmati rice',
        ],
        instructions:
            '1. Marinate chicken in yogurt, garam masala, turmeric for 1 hour.\n'
            '2. Grill or pan-fry chicken until charred.\n'
            '3. Sauté onion, garlic, ginger in a pot.\n'
            '4. Add tomato sauce, cumin, garam masala. Simmer 15 min.\n'
            '5. Add cream and cooked chicken. Simmer 10 min.\n'
            '6. Serve over basmati rice, garnish with cilantro.',
        cuisineType: 'Indian',
        prepTime: 60,
        difficulty: Difficulty.medium,
        tags: ['dinner', 'spicy', 'slow-cook'],
        status: RecipeStatus.madeBefore,
        createdAt: now.subtract(Duration(days: 8)),
        updatedAt: now.subtract(Duration(days: 8)),
      ),
      Recipe(
        id: uuid.v4(),
        userId: alice.id,
        name: 'Pad Thai',
        ingredients: [
          'rice noodles', 'shrimp', 'egg', 'bean sprouts', 'green onion',
          'peanuts', 'lime', 'fish sauce', 'tamarind paste', 'sugar',
          'garlic', 'thai basil',
        ],
        instructions:
            '1. Soak rice noodles in warm water for 20 minutes.\n'
            '2. Mix tamarind paste, fish sauce, and sugar for sauce.\n'
            '3. Stir-fry shrimp and garlic. Push aside, scramble egg.\n'
            '4. Add drained noodles and sauce. Toss well.\n'
            '5. Add bean sprouts and green onion.\n'
            '6. Serve with crushed peanuts and lime wedges.',
        cuisineType: 'Thai',
        prepTime: 35,
        difficulty: Difficulty.medium,
        tags: ['dinner', 'seafood'],
        status: RecipeStatus.toTry,
        createdAt: now.subtract(Duration(days: 5)),
        updatedAt: now.subtract(Duration(days: 5)),
      ),
      Recipe(
        id: uuid.v4(),
        userId: alice.id,
        name: 'Chocolate Chip Cookies',
        ingredients: [
          'flour', 'butter', 'sugar', 'brown sugar', 'eggs',
          'vanilla extract', 'baking soda', 'salt', 'chocolate chips',
        ],
        instructions:
            '1. Preheat oven to 375°F (190°C).\n'
            '2. Cream butter with both sugars until fluffy.\n'
            '3. Beat in eggs and vanilla.\n'
            '4. Mix in flour, baking soda, and salt.\n'
            '5. Fold in chocolate chips.\n'
            '6. Drop spoonfuls onto baking sheet.\n'
            '7. Bake 9-11 minutes until golden edges.',
        cuisineType: 'American',
        prepTime: 25,
        difficulty: Difficulty.easy,
        tags: ['dessert', 'baking', 'under-30-min'],
        status: RecipeStatus.favorite,
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now.subtract(Duration(days: 3)),
      ),
    ];

    // ── Bob's recipes ────────────────────────────────────────────────────
    final bobRecipes = <Recipe>[
      Recipe(
        id: uuid.v4(),
        userId: bob.id,
        name: 'Beef Tacos',
        ingredients: [
          'ground beef', 'tortilla', 'cheese', 'lettuce', 'tomato',
          'sour cream', 'salsa', 'cumin', 'chili powder', 'onion', 'garlic',
        ],
        instructions:
            '1. Brown ground beef with onion and garlic.\n'
            '2. Add cumin and chili powder, cook 2 more minutes.\n'
            '3. Warm tortillas in a dry pan.\n'
            '4. Fill tortillas with beef, top with cheese, lettuce, tomato.\n'
            '5. Add sour cream and salsa to taste.',
        cuisineType: 'Mexican',
        prepTime: 20,
        difficulty: Difficulty.easy,
        tags: ['dinner', 'quick', 'under-30-min'],
        status: RecipeStatus.favorite,
        createdAt: now.subtract(Duration(days: 7)),
        updatedAt: now.subtract(Duration(days: 7)),
      ),
      Recipe(
        id: uuid.v4(),
        userId: bob.id,
        name: 'Miso Ramen',
        ingredients: [
          'ramen noodles', 'miso paste', 'dashi', 'soy sauce', 'pork belly',
          'soft-boiled egg', 'green onion', 'nori', 'sesame oil', 'garlic',
          'ginger', 'corn',
        ],
        instructions:
            '1. Make broth: simmer dashi, miso, soy sauce, garlic, ginger.\n'
            '2. Slice and sear pork belly until caramelized.\n'
            '3. Cook ramen noodles according to package.\n'
            '4. Assemble: noodles in bowl, pour hot broth.\n'
            '5. Top with pork, halved soft-boiled egg, corn, nori, green onion.\n'
            '6. Drizzle with sesame oil.',
        cuisineType: 'Japanese',
        prepTime: 45,
        difficulty: Difficulty.hard,
        tags: ['dinner', 'soup', 'comfort-food'],
        status: RecipeStatus.madeBefore,
        createdAt: now.subtract(Duration(days: 6)),
        updatedAt: now.subtract(Duration(days: 6)),
      ),
      Recipe(
        id: uuid.v4(),
        userId: bob.id,
        name: 'Greek Salad',
        ingredients: [
          'cucumber', 'tomato', 'red onion', 'feta cheese', 'kalamata olives',
          'olive oil', 'lemon', 'oregano', 'salt', 'pepper',
        ],
        instructions:
            '1. Chop cucumber, tomato, and red onion into chunks.\n'
            '2. Add kalamata olives.\n'
            '3. Crumble feta cheese on top.\n'
            '4. Dress with olive oil, lemon juice, oregano, salt, pepper.\n'
            '5. Toss gently and serve immediately.',
        cuisineType: 'Mediterranean',
        prepTime: 10,
        difficulty: Difficulty.easy,
        tags: ['salad', 'vegetarian', 'quick', 'healthy'],
        status: RecipeStatus.none,
        createdAt: now.subtract(Duration(days: 2)),
        updatedAt: now.subtract(Duration(days: 2)),
      ),
    ];

    for (final r in [...aliceRecipes, ...bobRecipes]) {
      await storage.saveRecipe(r);
    }
  }
}

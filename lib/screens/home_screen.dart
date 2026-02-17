import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/filter_bar.dart';
import 'login_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser!.id;
      context.read<RecipeProvider>().loadRecipes(userId);
    });
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    context.read<RecipeProvider>().clearFilters('');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _confirmDelete(Recipe recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Delete "${recipe.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final userId = context.read<AuthProvider>().currentUser!.id;
              context.read<RecipeProvider>().deleteRecipe(recipe.id, userId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final recipeProv = context.watch<RecipeProvider>();
    final user = auth.currentUser!;
    final recipes = recipeProv.recipes;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes — ${user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
          recipeProv.loadRecipes(user.id);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Recipe'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          recipeProv.setSearchQuery('', user.id);
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => recipeProv.setSearchQuery(v, user.id),
            ),
          ),

          // Filter bar
          FilterBar(
            cuisines: recipeProv.availableCuisines,
            selectedCuisine: recipeProv.filterCuisine,
            hasActiveFilters: recipeProv.hasActiveFilters,
            onFilterChanged: ({cuisine, difficulty, status, maxPrepTime}) {
              recipeProv.setFilters(
                cuisine: cuisine ?? recipeProv.filterCuisine,
                difficulty: difficulty,
                status: status,
                maxPrepTime: maxPrepTime,
                userId: user.id,
              );
            },
            onClear: () {
              _searchCtrl.clear();
              recipeProv.clearFilters(user.id);
            },
          ),

          // Recipe count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${recipes.length} recipe${recipes.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Recipe list / grid
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          recipeProv.hasActiveFilters || _searchCtrl.text.isNotEmpty
                              ? 'No recipes match your filters.'
                              : 'No recipes yet. Tap + to add one!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : isWide
                    ? _buildGrid(recipes)
                    : _buildList(recipes),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: recipes.length,
      itemBuilder: (_, i) => _card(recipes[i]),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: recipes.length,
      itemBuilder: (_, i) => _card(recipes[i]),
    );
  }

  Widget _card(Recipe r) {
    return RecipeCard(
      recipe: r,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: r.id)),
        );
        final userId = context.read<AuthProvider>().currentUser!.id;
        context.read<RecipeProvider>().loadRecipes(userId);
      },
      onDelete: () => _confirmDelete(r),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

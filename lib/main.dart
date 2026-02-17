import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/seed_data.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final storage = StorageService();
  await SeedData.seed(storage);

  runApp(RecipeManagerApp(storage: storage));
}

class RecipeManagerApp extends StatelessWidget {
  final StorageService storage;
  const RecipeManagerApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => RecipeProvider(storage)),
      ],
      child: Builder(builder: (context) {
        final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
        return MaterialApp(
          title: 'Recipe Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF4CAF50),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        );
      }),
    );
  }
}

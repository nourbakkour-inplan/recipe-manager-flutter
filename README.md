# Recipe Manager (AI-Powered)

A cross-platform Recipe Management System built entirely using AI-assisted development (Claude).

**Live Demo:** https://web-phi-eight-88.vercel.app

This application runs fully in the browser (Flutter Web) and includes:
- Multi-user authentication
- Full CRUD functionality
- Search & filtering
- Local AI-powered cuisine detection and recipe similarity
- No backend server required

## Features

- **Multi-user auth** — Register/login with username & password (stored locally via Hive)
- **Recipe CRUD** — Create, read, update, delete recipes with full metadata
- **Status tagging** — Mark recipes as Favorite, To Try, or Made Before
- **Search & filter** — By name, ingredient, cuisine, tags, prep time, difficulty
- **AI-powered tools** (local, no API key needed):
  - Auto-detect cuisine type from recipe name & ingredients
  - Suggest missing ingredients based on common pairings
  - Auto-generate tags (diet, meal type, speed, difficulty)
  - Find similar recipes using ingredient similarity (Jaccard)
- **Responsive UI** — Grid layout on wide screens, list on narrow
- **Persistent sessions** — Stay logged in across browser refreshes

## Tech Stack

| Layer        | Technology                          |
|-------------|--------------------------------------|
| Framework   | Flutter 3.x (Dart)                   |
| Storage     | Hive (IndexedDB on web)              |
| State       | Provider                             |
| AI          | Local algorithmic (no external API)  |
| Target      | Web (Chrome, Firefox, Safari, Edge)  |

## Live Testing

The app is deployed and ready to use — no installation required:

1. Open https://web-phi-eight-88.vercel.app in any modern browser
2. Log in with a demo account or register a new one:

| Username | Password   |
|----------|------------|
| alice    | pass1234   |
| bob      | pass1234   |

3. Each demo account comes with pre-loaded sample recipes
4. Try the features:
   - **Search & filter** — type in the search bar, use the cuisine/difficulty/status dropdowns
   - **Create a recipe** — tap "+ New Recipe", fill in the form
   - **AI: Auto-detect cuisine** — click the "Auto-detect" button next to the Cuisine field
   - **AI: Suggest ingredients** — click the lightbulb icon next to Ingredients
   - **AI: Auto-tag** — click "Auto-tag" in the Tags section
   - **AI: Find similar** — open a recipe detail, click "Find Similar Recipes"
   - **Status tagging** — mark recipes as Favorite, To Try, or Made Before

> **Note:** Data is stored in your browser's IndexedDB. Each browser/device has its own independent data. Clearing browser data resets everything (demo data re-seeds automatically).

## Local Development

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- Chrome browser

### Install & Run

```bash
cd RecipeManager
flutter pub get
flutter run -d chrome
```

## Build for Production

```bash
flutter build web --release
```

Output is in `build/web/`. Deploy this folder to any static hosting.

## Deploy

### Netlify

1. Build: `flutter build web --release`
2. Drag-and-drop `build/web/` to [app.netlify.com/drop](https://app.netlify.com/drop)
3. Or use the CLI:
   ```bash
   npm install -g netlify-cli
   netlify deploy --prod --dir=build/web
   ```

### Vercel

1. Build: `flutter build web --release`
2. Install Vercel CLI: `npm install -g vercel`
3. Deploy:
   ```bash
   cd build/web
   vercel --prod
   ```

### Firebase Hosting

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize:
   ```bash
   firebase login
   firebase init hosting
   # Set public directory to: build/web
   # Configure as single-page app: Yes
   ```
3. Build and deploy:
   ```bash
   flutter build web --release
   firebase deploy
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── user.dart                # User model + Hive adapter
│   └── recipe.dart              # Recipe model + enums + Hive adapter
├── services/
│   ├── storage_service.dart     # Hive box management
│   ├── auth_service.dart        # Registration, login, sessions
│   ├── recipe_service.dart      # CRUD + search/filter logic
│   ├── ai_service.dart          # Cuisine detection, similarity, suggestions
│   └── seed_data.dart           # Sample data for testing
├── providers/
│   ├── auth_provider.dart       # Auth state (ChangeNotifier)
│   └── recipe_provider.dart     # Recipe state + AI features
├── screens/
│   ├── login_screen.dart        # Login page
│   ├── register_screen.dart     # Registration page
│   ├── home_screen.dart         # Recipe list with search/filter
│   ├── recipe_detail_screen.dart # Full recipe view + AI tools
│   └── recipe_form_screen.dart  # Add/edit recipe form + AI helpers
└── widgets/
    ├── recipe_card.dart         # Recipe summary card
    ├── filter_bar.dart          # Horizontal filter controls
    └── ai_suggestions_dialog.dart # Similar recipes & ingredient suggestion dialogs
```

## AI Features Explained

All AI runs locally in Dart — no API keys, no network calls.

| Feature | How It Works |
|---------|-------------|
| **Cuisine detection** | Matches recipe name + ingredients against keyword dictionaries for 10 cuisines |
| **Similar recipes** | Jaccard similarity coefficient on normalized ingredient sets |
| **Missing ingredients** | Co-occurrence patterns from 15 common ingredient groups |
| **Auto-tagging** | Rule-based: diet detection (vegan/vegetarian), meal type, speed, difficulty |

## License

MIT

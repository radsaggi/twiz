# Twiz Library Code Structure

This directory contains the core logic and UI components for the Twiz Flutter application.

## Directory Layout

- `pages/`: Contains the main screens of the application (Categories, Question).
- `widgets/`: Contains reusable UI components (Scoreboard, Team Options).
- `display.dart`: Handles responsive UI scaling and layout configuration.
- `global_state.dart`: Defines global application state and data models.
- `main.dart`: Application entry point and dependency injection setup.

## Key Components

### 1. Application Entry Point (`main.dart`)
- **Responsibility**: Initializes the Flutter app, sets up providers, and defines routes.
- **State Management**: Uses `MultiProvider` to inject `GlobalScoreboard` and `GlobalData` at the root.
- **Routing**: Defines named routes for `CategoriesDisplayWidget2` and `QuestionDisplayWidget`.
- **Theme**: Configures a global theme based on a seed color (`Colors.blueGrey`).

### 2. Global State (`global_state.dart`)
- **Data Models**:
    - `CategoriesData`: Manages the list of categories and questions. Supports JSON deserialization.
    - `QuestionData`: Represents a single question with a title, description, and list of clues.
    - `ClueData`: Represents a clue with prompts, hints, and an answer.
- **State Providers**:
    - `GlobalScoreboard`: Manages team names, scores, and colors. Extends `ChangeNotifier`.
    - `GlobalData`: Holds the application data (categories, questions) and handles file uploads (JSON). Extends `ChangeNotifier`.

### 3. Display Logic (`display.dart`)
- **Responsibility**: Provides a centralized way to manage responsive design.
- **Class**: `DisplayCharacterstics`
    - Calculates scaling factors based on screen size.
    - Provides helpers for padding, icon sizes, text scaling, and spacers.
    - **Pattern**: Uses a factory constructor `forSize` to create instances derived from the current media query, and a `wrapped` helper to inject it via `Provider`.

## Design Choices

- **State Management**: The app uses `Provider` (specifically `ChangeNotifierProvider` and `ProxyProvider`) for state management. This allows for reactive updates when data changes (e.g., score updates, category status changes).
- **Responsive Design**: Instead of hardcoding sizes, the app uses `DisplayCharacterstics` to scale UI elements proportionally to the screen size, ensuring usability across different devices.
- **Data Persistence**: Data is loaded from JSON files, allowing for dynamic content without app updates. The `GlobalData` class handles this logic.


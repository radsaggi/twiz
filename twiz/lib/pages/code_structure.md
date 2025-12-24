# Pages Code Structure

This directory contains the main screens (pages) of the application.

## Files

- `categories2.dart`: The main dashboard displaying game categories.
- `question.dart`: The detail screen for a specific question and its clues.

## Components

### 1. Categories Page (`categories2.dart`)
- **Widget**: `CategoriesDisplayWidget2`
- **State Management**:
    - Uses a local `_CategoriesState` (via `ChangeNotifier`) to track the status of each category (`HIDDEN`, `REVEALED`, `EXHAUSTED`).
    - Connects to `GlobalData` to render the grid of categories.
- **UI Structure**:
    - **AppBar**: Contains settings, data loader, and a mini scoreboard.
    - **Grid**: Displays categories using `_AnimatedCategoriesWidget`.
    - **Animations**: Uses `AnimatedSwitcher` with a custom flip transition (`__transitionBuilder`) to animate revealing categories.
    - **Interaction**: Tapping a hidden category reveals it. Tapping a revealed category navigates to the `QuestionDisplayWidget`.
- **Data Loader**: `_DataLoaderIcon` allows users to upload a JSON file to populate game data.

### 2. Question Page (`question.dart`)
- **Widget**: `QuestionDisplayWidget`
- **State Management**:
    - Uses a local `QuestionState` to manage the reveal phase of clues (`EMPTY`, `SHOW_CLUE1`, `SHOW_CLUE2`).
    - Receives `QuestionData` via route arguments.
- **UI Structure**:
    - **AppBar**: Shows question title, navigation, settings, and controls to reveal clues.
    - **Body**: Split into `QuestionTitleWidget` and `ClueGridWidget`.
    - **Clue Grid**: Displays a grid of clues.
        - `_ClueScoreDisplayWidget`: Shows the point value for the column.
        - `ClueDisplayWidget`: Displays individual clues.
    - **Clue Interaction**:
        - `ClueAnswerButtonWidget`: A button that reveals the answer when clicked (`_buildAnswerOverlay`).
        - `ClueTextWidget`: Displays the hint text, animating between hints based on `QuestionState`.

## Design Decisions

- **Local vs Global State**: Page-specific state (like which clues are revealed or category visibility) is managed locally within the page widget using `ChangeNotifierProvider`, isolating it from the global application state.
- **Animations**: Custom animations (flip cards, sliding transitions) are used to enhance the user experience and make the game feel interactive.
- **Responsiveness**: Both pages heavily utilize `DisplayCharacterstics` (from parent directory) to ensure text and elements scale correctly.


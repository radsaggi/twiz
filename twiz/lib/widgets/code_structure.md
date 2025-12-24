# Widgets Code Structure

This directory contains reusable UI components used across the application.

## Files

- `scoreboard_full.dart`: The interactive full-screen scoreboard.
- `scoreboard_mini.dart`: A compact summary of the scoreboard.
- `team_options.dart`: Settings widget for customizing team details.

## Components

### 1. Full Scoreboard (`scoreboard_full.dart`)
- **Widget**: `ScoreBoardFullWidget`
- **Functionality**:
    - Displays score counters for all teams.
    - Allows incrementing/decrementing scores.
- **Internal Components**:
    - `_ScoreCounter`: A stateful widget that handles the animation and logic for changing a single team's score.
    - **Animation**: Uses `SlideTransition` to animate numbers rolling up or down when the score changes.

### 2. Mini Scoreboard (`scoreboard_mini.dart`)
- **Widget**: `ScoreBoardMiniWidget`
- **Functionality**:
    - Provides a quick view of current scores in the AppBar.
    - Opens the `ScoreBoardFullWidget` in a dialog when tapped.
- **Responsive Dialog**:
    - Checks screen width to decide whether to show a full-screen dialog or an `AlertDialog`.

### 3. Team Options (`team_options.dart`)
- **Widget**: `TeamOptionsPopopWidget`
- **Functionality**:
    - Allows editing team names and colors.
    - Updates `GlobalScoreboard` state.
- **Mixin**: `TeamOptionsPopopWidgetProvider` provides a helper method `provideUsing` to inject necessary providers when showing this widget in a dialog (since dialogs exist in a new widget tree root).
- **Internal Components**:
    - `_TeamIndexCounter`: Manages the UI for a specific team's settings, including a color picker and text input field.

## UI Composition Decisions

- **Modularity**: The scoreboard logic is split into "Mini" and "Full" versions to serve different contexts (AppBar vs Dialog) while sharing the same underlying data source (`GlobalScoreboard`).
- **Provider Injection**: The `TeamOptionsPopopWidgetProvider` mixin solves the common Flutter issue where dialogs lose access to inherited widgets (like Providers) by explicitly re-injecting them.
- **Customization**: Widgets are designed to be customizable via `GlobalScoreboard`, allowing users to personalize the game experience (names, colors).


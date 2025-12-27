# Widgets Code Structure

This directory contains reusable UI components used across the application.

## Files

- `scoreboard_full.dart`: The interactive full-screen scoreboard.
- `scoreboard_mini.dart`: A compact summary of the scoreboard.

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

## UI Composition Decisions

- **Modularity**: The scoreboard logic is split into "Mini" and "Full" versions to serve different contexts (AppBar vs Dialog) while sharing the same underlying data source (`GlobalScoreboard`).
- **Customization**: Widgets are designed to be customizable via `GlobalScoreboard`, allowing users to personalize the game experience (names, colors).


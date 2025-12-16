# Debate Tournament App - Dart/Flutter Conversion

## Overview
Successfully converted the C# debate tournament application to Dart/Flutter while maintaining all original functionality.

## File Structure

### Models (`lib/models/`)
- **`debater.dart`** - Individual debater with scoring capabilities
- **`debate_team.dart`** - Team with 3 debaters, wins/losses tracking
- **`debate_match.dart`** - Match between two teams with score submission
- **`tournament.dart`** - Main tournament class with teams and matches
- **`tournament_segment.dart`** - Tournament stages and segments

### Services (`lib/services/`)
- **`match_mashup.dart`** - Matchup generation algorithms
- **`score_manager.dart`** - Score management and tournament advancement
- **`data_manager.dart`** - JSON-based data persistence (replaces Excel)

### Controllers (`lib/controllers/`)
- **`dash.dart`** - Main application logic and flow control

### Screens (`lib/screens/`)
- **`home_screen.dart`** - Main menu interface
- **`create_tournament_screen.dart`** - Tournament creation form
- **`tournament_management_screen.dart`** - Tournament management dashboard
- **`add_team_screen.dart`** - Team addition form
- **`match_results_screen.dart`** - Match result entry interface

### Entry Points
- **`lib/main.dart`** - Console application entry point
- **`lib/flutter_main.dart`** - Flutter GUI application entry point

## Key Changes from C# to Dart

### 1. Data Types
- `string` → `String`
- `int` → `int` (same)
- `double` → `double` (same)
- `bool` → `bool` (same)
- `List<T>` → `List<T>` (same syntax)
- `enum` → `enum` (with extensions for display names)

### 2. Language Features
- **Properties**: C# auto-properties → Dart class fields
- **Constructors**: Named parameters with required/optional
- **Null Safety**: Dart's built-in null safety
- **Async/Await**: Similar syntax, but with `Future<T>`

### 3. Data Persistence
- **Excel (ClosedXML)** → **JSON files** for simpler mobile compatibility
- Added CSV export for compatibility
- File system operations adapted for cross-platform support

### 4. UI Framework
- **Console.WriteLine** → **Flutter widgets** for mobile UI
- Form validation and input handling
- Material Design components
- Navigation between screens

### 5. Error Handling
- Try-catch blocks maintained
- Added UI feedback through SnackBars
- Graceful error recovery

## Features Preserved

✅ **Tournament Creation** - Create tournaments with name, year, club  
✅ **Team Management** - Add/remove teams with 3 debaters each  
✅ **Matchup Generation** - All original algorithms preserved  
✅ **Score Management** - Individual and team scoring  
✅ **Tournament Progression** - Advance through segments  
✅ **Top Performers** - Ranking and top debater/team identification  
✅ **Data Export** - JSON and CSV formats  
✅ **Data Persistence** - Load/save tournaments  

## Running the Application

### Console Version
```bash
dart run lib/main.dart
```

### Flutter GUI Version
```bash
flutter run lib/flutter_main.dart
```

## Dependencies
- `path` - File path operations
- `shared_preferences` - Local storage for Flutter
- `file_picker` - File selection capabilities
- `csv` - CSV export functionality

## Architecture Benefits

1. **Separation of Concerns** - Models, services, controllers, and UI separated
2. **Testability** - Each component can be unit tested
3. **Scalability** - Easy to add new features or modify existing ones
4. **Cross-Platform** - Runs on Android, iOS, Web, Desktop
5. **Modern UI** - Material Design for better user experience
6. **Async Operations** - Non-blocking operations for better performance

## Future Enhancements
- Cloud data synchronization
- Real-time match updates
- Advanced analytics and reporting
- Multi-tournament management
- Tournament templates
- Backup and restore functionality
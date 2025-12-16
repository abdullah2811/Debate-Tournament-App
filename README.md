# Debate Tournament Tab System

A comprehensive Flutter application for managing debate tournaments, converted from C# to Dart while maintaining all original functionality.

## Features

🏆 **Tournament Management**
- Create and manage multiple tournaments
- Track tournament progression through segments (Preliminary 1-3, Octa/Quarter/Semi/Final)
- Export tournament data to JSON and CSV formats

👥 **Team Management**
- Add/remove teams with exactly 3 debaters each
- Track team scores, wins, and losses
- View detailed team information and member details

⚔️ **Match Management**
- Automatic matchup generation based on tournament segment
- Smart pairing algorithms (random for first round, performance-based for subsequent rounds)
- Score entry with individual debater scores and rebuttal scores
- Tie-breaking functionality

📊 **Scoring & Analytics**
- Individual debater scoring
- Team scoring and ranking
- Top performers identification
- Tournament advancement based on performance

💾 **Data Persistence**
- JSON-based data storage for cross-platform compatibility
- CSV export for external analysis
- Load/save tournament states
- Tournament history management

## Installation

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK (included with Flutter)

### Setup
1. Clone or download this repository
2. Navigate to the project directory
3. Get dependencies:
   ```bash
   flutter pub get
   ```

## Running the Application

### Flutter GUI Application (Recommended)
```bash
flutter run lib/flutter_main.dart
```

### Console Application
```bash
dart run lib/main.dart
```

## Project Structure

```
lib/
├── controllers/          # Application logic controllers
│   └── dash.dart
├── models/              # Data models
│   ├── debater.dart
│   ├── debate_team.dart
│   ├── debate_match.dart
│   ├── tournament.dart
│   └── tournament_segment.dart
├── services/            # Business logic services
│   ├── match_mashup.dart
│   ├── score_manager.dart
│   └── data_manager.dart
├── screens/             # Flutter UI screens
│   ├── home_screen.dart
│   ├── create_tournament_screen.dart
│   ├── tournament_management_screen.dart
│   ├── add_team_screen.dart
│   └── match_results_screen.dart
├── main.dart           # Console application entry
└── flutter_main.dart   # Flutter application entry
```

## Usage Guide

### Creating a Tournament
1. Launch the app
2. Select "Create Tournament"
3. Enter tournament name, year, and club name
4. Tournament is automatically saved

### Adding Teams
1. Select "Run Tournament" → Choose your tournament
2. Click "Add Team"
3. Enter team name and 3 debater details
4. Team is added to the tournament

### Running Matches
1. Click "Show Matchups" to generate current round matchups
2. Click "Enter Results" to input match scores
3. Enter individual debater scores and rebuttal scores
4. System automatically determines winner and updates rankings

### Advancing Tournament
1. Complete all matches in current segment
2. Click "Advance Segment" to move to next round
3. System automatically eliminates teams based on performance for elimination rounds

### Viewing Results
- Click "View Teams" to see all teams and their standings
- Click "Top Performers" to see top teams and debaters
- Click "Export Data" to save results as JSON/CSV files

## Dependencies

- **flutter**: Framework for building cross-platform applications
- **path**: File and directory path operations
- **shared_preferences**: Local storage for Flutter applications
- **file_picker**: File selection capabilities
- **csv**: CSV file generation and parsing

## Data Storage

- Tournament data is stored in JSON format in the `tournament_records/` directory
- Matchup data is stored in the `tournament_docs/` directory
- CSV exports are also saved in the `tournament_records/` directory for external analysis

## Tournament Flow

1. **Preliminary Rounds (1-3)**: Teams compete in multiple preliminary rounds
2. **Elimination Rounds**: Top 16 teams advance to Octa-finals
3. **Progressive Elimination**: Quarter-finals (8 teams) → Semi-finals (4 teams) → Finals (2 teams)
4. **Scoring**: Individual debater scores + rebuttal scores determine match winners

## Original C# Conversion

This application was converted from a C# console application to Dart/Flutter while preserving all original functionality:

- **Excel data storage** → **JSON/CSV data storage**
- **Console UI** → **Flutter Material Design UI**
- **Synchronous operations** → **Asynchronous operations**
- **Windows-specific paths** → **Cross-platform file operations**

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues or questions, please create an issue in the project repository or contact the development team.

---

**Developed for debate tournament organizers to efficiently manage competitions and track participant performance.**
// import 'dart:io';
// import '../models/tournament.dart';
// import '../models/tournament_segment.dart';
// import '../services/data_manager.dart';
// import '../services/match_mashup.dart';
// import '../services/score_manager.dart';

// class Dash {
//   static Future<Tournament> createTournament({
//     Future<String> Function(String)? inputCallback,
//     Function(String)? onMessage,
//   }) async {
//     String name, year, club;

//     if (inputCallback != null) {
//       name = await inputCallback("Enter tournament name:");
//       year = await inputCallback("Enter tournament year:");
//       club = await inputCallback("Enter club name:");
//     } else {
//       print("Enter tournament name:");
//       name = stdin.readLineSync() ?? '';
//       print("Enter tournament year:");
//       year = stdin.readLineSync() ?? '';
//       print("Enter club name:");
//       club = stdin.readLineSync() ?? '';
//     }

//     Tournament newTournament = Tournament(
//       clubName: club,
//       tournamentName: name,
//       tournamentYear: year,
//     );

//     await DataManager.saveTournamentToJson(newTournament);

//     if (onMessage != null) {
//       onMessage("Tournament created successfully!");
//     } else {
//       print(
//           "Tournament created successfully. Press any key to return to the main menu!");
//     }

//     return newTournament;
//   }

//   static Future<void> runTournamentMenu(
//     Tournament tournament, {
//     Function(String, List<String>)? onShowMenu,
//     Future<String> Function(String)? inputCallback,
//     Function(String)? onMessage,
//     Function()? onReturn,
//   }) async {
//     while (true) {
//       List<String> menuOptions = [
//         "Add a team",
//         "Remove a team",
//         "View all teams",
//         "Show Matchups for Current Segment",
//         "Enter Match Results",
//         "Export Data",
//         "Advance Segment",
//         "Back to main menu",
//         "Get Tops",
//       ];

//       String menuTitle =
//           "Running Tournament: ${tournament.tournamentName} (${tournament.tournamentYear})\n"
//           "Current Segment: ${tournament.currentSegment.displayName}";

//       String choice;
//       if (onShowMenu != null) {
//         onShowMenu(menuTitle, menuOptions);
//         choice = await inputCallback?.call("Enter your choice:") ?? '';
//       } else {
//         print(menuTitle);
//         for (int i = 0; i < menuOptions.length; i++) {
//           print("${i + 1}. ${menuOptions[i]}");
//         }
//         print("Enter your choice:");
//         choice = stdin.readLineSync() ?? '';
//       }

//       switch (choice) {
//         case "1":
//           await Tournament.addTeam(
//             tournament,
//             inputCallback: inputCallback,
//             onSuccess: onMessage,
//             onError: onMessage,
//           );
//           await DataManager.saveTournamentToJson(tournament);
//           break;

//         case "2":
//           await Tournament.removeTeam(
//             tournament,
//             inputCallback: inputCallback,
//             onSuccess: onMessage,
//             onError: onMessage,
//           );
//           await DataManager.saveTournamentToJson(tournament);
//           break;

//         case "3":
//           Tournament.viewTeams(tournament);
//           break;

//         case "4":
//           MatchMashup.showMatchups(tournament, onMessage: onMessage);
//           await DataManager.saveMatchupToJson(
//               tournament.currentMatches, tournament);
//           break;

//         case "5":
//           await ScoreManager.enterMatchResults(
//             tournament,
//             inputCallback: inputCallback,
//             onMessage: onMessage,
//           );
//           await DataManager.saveTournamentToJson(tournament);
//           break;

//         case "6":
//           await DataManager.saveTournamentToJson(tournament);
//           await DataManager.exportTournamentToCsv(tournament);
//           if (onMessage != null) {
//             onMessage("Data exported successfully!");
//           } else {
//             print("Data exported successfully! Press any key to continue...");
//           }
//           break;

//         case "7":
//           await ScoreManager.advanceSegment(tournament, onMessage: onMessage);
//           await DataManager.saveTournamentToJson(tournament);
//           break;

//         case "8":
//           if (onReturn != null) {
//             onReturn();
//           }
//           return;

//         case "9":
//           ScoreManager.showTopPerformers(tournament, onMessage: onMessage);
//           var topTeams = ScoreManager.getTopTeams(
//               tournament.teamsInTheTournament, tournament);
//           var topDebaters = ScoreManager.getTopDebaters(
//               tournament.teamsInTheTournament, tournament);
//           await DataManager.saveTopTeamsToJson(topTeams, tournament);
//           await DataManager.saveTopDebatersToJson(topDebaters, tournament);
//           break;

//         default:
//           if (onMessage != null) {
//             onMessage("Invalid choice. Please try again.");
//           } else {
//             print("Invalid choice. Press any key to try again.");
//           }
//           break;
//       }
//     }
//   }

//   static Future<bool> confirmExit({
//     Future<String> Function(String)? inputCallback,
//     Future<bool> Function(String)? confirmCallback,
//   }) async {
//     if (confirmCallback != null) {
//       return await confirmCallback("Are you sure you want to exit?");
//     }

//     if (inputCallback != null) {
//       String input =
//           await inputCallback("Are you sure you want to exit? (y/n):");
//       return input.toLowerCase() == "y" || input.toLowerCase() == "yes";
//     }

//     print("Are you sure you want to exit? (y/n):");
//     String input = (stdin.readLineSync() ?? '').toLowerCase();
//     return input == "y" || input == "yes";
//   }
// }

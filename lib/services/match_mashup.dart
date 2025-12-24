// //import 'dart:math';
// import '../models/tournament.dart';
// import '../models/debate_team.dart';
// import '../models/debate_match.dart';
// import '../models/tournament_segment.dart';
// import 'score_manager.dart';

// class MatchMashup {
//   // Method to create and return a list of pairs of teams for a given segment and list of teams
//   static List<(DebateTeam, DebateTeam)> preliminarySegmentFirstMatchup(
//       List<DebateTeam> teams) {
//     List<(DebateTeam, DebateTeam)> matchups = [];

//     // Ensure there are an even number of teams
//     if (teams.length % 2 != 0) {
//       throw ArgumentError("Number of teams must be even for pairing.");
//     }

//     // Create pairs of teams
//     for (int i = 0; i < teams.length; i += 2) {
//       matchups.add((teams[i], teams[i + 1]));
//     }

//     return matchups;
//   }

//   // For the second matchup, we will make list of debating pairs based on the first matchup.
//   // The winning teams will fight against the winning teams and the losing teams will fight the losing teams.
//   static List<(DebateTeam, DebateTeam)> preliminarySegmentWinWinLoseLoseMatchup(
//       List<DebateTeam> teams) {
//     List<DebateTeam> winningTeams = [];
//     List<DebateTeam> losingTeams = [];
//     List<(DebateTeam, DebateTeam)> matchups = [];

//     // Add values to the winning and losing teams list
//     winningTeams =
//         teams.where((t) => t.teamStatus == DebateTeamStatus.win).toList();
//     losingTeams =
//         teams.where((t) => t.teamStatus == DebateTeamStatus.lose).toList();

//     // Winning teams: sort by number of wins (descending), then team score (descending)
//     winningTeams.sort((a, b) {
//       int winsComparison = b.teamWins.compareTo(a.teamWins);
//       if (winsComparison != 0) return winsComparison;
//       return b.teamScore.compareTo(a.teamScore);
//     });

//     // Losing teams: sort by number of wins (descending), then team score (ascending)
//     losingTeams.sort((a, b) {
//       int winsComparison = b.teamWins.compareTo(a.teamWins);
//       if (winsComparison != 0) return winsComparison;
//       return a.teamScore.compareTo(b.teamScore);
//     });

//     if (winningTeams.length != losingTeams.length || winningTeams.isEmpty) {
//       throw ArgumentError(
//           "Number of winning and losing teams must be equal and more than 0.");
//     }

//     // Ensure both are even AND equal
//     if (winningTeams.length % 2 != 0 && losingTeams.length % 2 != 0) {
//       // Move one team from winning to losing to balance pairing
//       DebateTeam lastWinningTeam = winningTeams.removeLast();
//       losingTeams.add(lastWinningTeam); // Add to end to maintain ordering
//     } else if (winningTeams.length != losingTeams.length ||
//         (winningTeams.length % 2 != 0 || losingTeams.length % 2 != 0)) {
//       throw ArgumentError(
//           "Team counts must be equal and even for proper matchup generation.");
//     }

//     // Build the matchups. Initially, make pairs among the winning teams.
//     // The highest scoring team will fight against the next highest scoring team.
//     int n = winningTeams.length;
//     for (int i = 0; i < n; i += 2) {
//       matchups.add((winningTeams[i], winningTeams[i + 1]));
//     }
//     for (int i = 0; i < n; i += 2) {
//       matchups.add((losingTeams[i], losingTeams[i + 1]));
//     }

//     return matchups;
//   }

//   static List<(DebateTeam, DebateTeam)> quarterSemiFinalSegmentMatchup(
//       List<DebateTeam> teams) {
//     List<(DebateTeam, DebateTeam)> matchups = [];

//     // Ensure there are an even number of teams
//     int n = teams.length;
//     if (n % 2 != 0) {
//       throw ArgumentError("Number of teams must be even for pairing.");
//     }

//     // Create pairs of teams
//     for (int i = 0; i < n ~/ 2; i++) {
//       matchups.add((teams[i], teams[n - 1 - i]));
//     }

//     return matchups;
//   }

//   static List<DebateMatch> generateMatchups(Tournament tournament,
//       {Function(String)? onMessage}) {
//     var teams = tournament.teamsInTheTournament;
//     List<(DebateTeam, DebateTeam)> pairs;

//     try {
//       switch (tournament.currentSegment) {
//         case TournamentStage.preliminary1:
//           pairs = MatchMashup.preliminarySegmentFirstMatchup(teams);
//           break;
//         case TournamentStage.preliminary2:
//         case TournamentStage.preliminary3:
//           pairs = MatchMashup.preliminarySegmentWinWinLoseLoseMatchup(teams);
//           break;
//         case TournamentStage.octaFinal:
//         case TournamentStage.quarterFinal:
//         case TournamentStage.semiFinal:
//         case TournamentStage.finalStage:
//           ScoreManager.resetScores(teams, tournament);
//           pairs = MatchMashup.quarterSemiFinalSegmentMatchup(teams);
//           break;
//       }

//       tournament.currentMatches.clear();
//       for (var (a, b) in pairs) {
//         tournament.currentMatches.add(DebateMatch(teamA: a, teamB: b));
//       }

//       return tournament.currentMatches;
//     } catch (e) {
//       if (onMessage != null) {
//         onMessage("Error generating matchups: $e");
//       } else {
//         print("Error generating matchups: $e");
//       }
//       return <DebateMatch>[];
//     }
//   }

//   static void showMatchups(Tournament tournament,
//       {Function(List<DebateMatch>)? onMatchupsGenerated,
//       Function(String)? onMessage}) {
//     tournament.currentMatches =
//         MatchMashup.generateMatchups(tournament, onMessage: onMessage);

//     if (onMatchupsGenerated != null) {
//       onMatchupsGenerated(tournament.currentMatches);
//     } else {
//       print("Matchups generated:");
//       for (var match in tournament.currentMatches) {
//         print("Match: ${match.teamA.teamName} vs ${match.teamB.teamName}");
//       }
//       print("Press any key to continue...");
//     }
//   }
// }

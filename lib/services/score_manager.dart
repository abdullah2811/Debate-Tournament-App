import 'dart:io';
import '../models/tournament.dart';
import '../models/debate_team.dart';
import '../models/debater.dart';
import '../models/debate_match.dart';
import '../models/tournament_segment.dart';
import 'match_mashup.dart';

class ScoreManager {
  static List<Debater> getTopDebaters(
      List<DebateTeam> teams, Tournament tournament,
      {int topN = 5}) {
    List<Debater> allDebaters = [];
    for (var team in teams) {
      allDebaters.addAll(team.teamMembers.cast<Debater>());
    }

    // Sort debaters by individual score and take the top N
    List<Debater> sortedDebaters = allDebaters.toList()
      ..sort((a, b) => b.individualScore.compareTo(a.individualScore));

    // If there are fewer debaters than topN, return all of them
    if (sortedDebaters.length < topN) {
      return sortedDebaters;
    }

    return sortedDebaters.take(topN).toList();
  }

  static List<DebateTeam> getTopTeams(
      List<DebateTeam> teams, Tournament tournament,
      {int topN = 3}) {
    // Sort by number of wins first, then by team score
    List<DebateTeam> sortedTeams = teams.toList()
      ..sort((a, b) {
        int winsComparison = b.teamWins.compareTo(a.teamWins);
        if (winsComparison != 0) return winsComparison;
        return b.teamScore.compareTo(a.teamScore);
      });

    // Return all if less than topN
    if (sortedTeams.length < topN) {
      return sortedTeams;
    }

    return sortedTeams.take(topN).toList();
  }

  static Future<void> enterMatchResults(
    Tournament tournament, {
    Function(List<DebateMatch>)? onIncompleteMatchesFound,
    Function(String)? onMessage,
    Function()? onAllMatchesCompleted,
    Future<String> Function(String)? inputCallback,
    Future<bool> Function(String)? confirmCallback,
  }) async {
    if (tournament.currentMatches.isEmpty) {
      tournament.currentMatches = MatchMashup.generateMatchups(tournament);
    }

    while (true) {
      var incompleteMatches =
          tournament.currentMatches.where((m) => !m.isCompleted).toList();

      if (incompleteMatches.isEmpty) {
        String message = "✅ All match results have already been submitted.";

        bool shouldAdvance = false;
        if (confirmCallback != null) {
          shouldAdvance = await confirmCallback(
              "Do you want to advance to the next segment?");
        } else {
          print("$message\nDo you want to advance to the next segment? (y/n):");
          String? input = stdin.readLineSync()?.toLowerCase();
          shouldAdvance = input == "y" || input == "yes";
        }

        if (shouldAdvance) {
          await advanceSegment(tournament, onMessage: onMessage);
        } else {
          if (onMessage != null) {
            onMessage("Tournament stays in current segment.");
          } else {
            print("Tournament stays in current segment.");
          }
        }

        if (onAllMatchesCompleted != null) {
          onAllMatchesCompleted();
        }
        return;
      }

      if (onIncompleteMatchesFound != null) {
        onIncompleteMatchesFound(incompleteMatches);
      } else {
        print("📋 Incomplete Matches:");
        for (int i = 0; i < incompleteMatches.length; i++) {
          var match = incompleteMatches[i];
          print("${i + 1}. ${match.teamA.teamName} vs ${match.teamB.teamName}");
        }

        print("0. 🔙 Return to Tournament Menu");
        print("Select a match number to enter result:");
        String? choice = stdin.readLineSync();

        if (choice == "0") return;

        if (int.tryParse(choice ?? '') case int matchIndex
            when matchIndex >= 1 && matchIndex <= incompleteMatches.length) {
          var selectedMatch = incompleteMatches[matchIndex - 1];
          await _processMatchResult(selectedMatch,
              inputCallback: inputCallback);

          if (onMessage != null) {
            onMessage("✅ Result submitted! Tournament auto-saved.");
          } else {
            print("\n✅ Result submitted!");
            print("📁 Tournament auto-saved.");
            print("Press any key to return to match list.");
          }
        } else {
          if (onMessage != null) {
            onMessage("❌ Invalid choice. Please try again.");
          } else {
            print("❌ Invalid choice. Press any key to try again.");
          }
        }
      }
    }
  }

  static Future<void> _processMatchResult(
    DebateMatch match, {
    Future<String> Function(String)? inputCallback,
  }) async {
    DebateTeam teamA = match.teamA;
    DebateTeam teamB = match.teamB;

    List<int> aScores = List.filled(3, 0);
    List<int> bScores = List.filled(3, 0);

    // Get Team A scores
    for (int j = 0; j < 3; j++) {
      var debater = teamA.teamMembers[j] as Debater;
      String scoreStr;
      if (inputCallback != null) {
        scoreStr = await inputCallback(
            "Enter score for ${debater.name} (${teamA.teamName}):");
      } else {
        print("Enter score for ${debater.name} (${teamA.teamName}):");
        scoreStr = stdin.readLineSync() ?? '0';
      }
      aScores[j] = int.tryParse(scoreStr) ?? 0;
    }

    // Get Team A rebuttal
    String aRebuttalStr;
    if (inputCallback != null) {
      aRebuttalStr =
          await inputCallback("Enter rebuttal score for ${teamA.teamName}:");
    } else {
      print("Enter rebuttal score for ${teamA.teamName}:");
      aRebuttalStr = stdin.readLineSync() ?? '0';
    }
    int aRebuttal = int.tryParse(aRebuttalStr) ?? 0;

    // Get Team B scores
    for (int j = 0; j < 3; j++) {
      var debater = teamB.teamMembers[j] as Debater;
      String scoreStr;
      if (inputCallback != null) {
        scoreStr = await inputCallback(
            "Enter score for ${debater.name} (${teamB.teamName}):");
      } else {
        print("Enter score for ${debater.name} (${teamB.teamName}):");
        scoreStr = stdin.readLineSync() ?? '0';
      }
      bScores[j] = int.tryParse(scoreStr) ?? 0;
    }

    // Get Team B rebuttal
    String bRebuttalStr;
    if (inputCallback != null) {
      bRebuttalStr =
          await inputCallback("Enter rebuttal score for ${teamB.teamName}:");
    } else {
      print("Enter rebuttal score for ${teamB.teamName}:");
      bRebuttalStr = stdin.readLineSync() ?? '0';
    }
    int bRebuttal = int.tryParse(bRebuttalStr) ?? 0;

    await match.submitScores(aScores, aRebuttal, bScores, bRebuttal);
  }

  static void resetScores(List<DebateTeam> teams, Tournament tournament) {
    // Reset the scores of all teams and debaters
    for (var team in teams) {
      team.teamScore = 0;
      team.teamWins = 0;
      team.teamLosses = 0;
      team.teamStatus = DebateTeamStatus.notPlayed;

      for (var debater in team.teamMembers.cast<Debater>()) {
        debater.individualScore = 0;
      }
    }
  }

  static void showTopPerformers(
    Tournament tournament, {
    Function(List<DebateTeam>, List<Debater>)? onTopPerformersRetrieved,
    Function(String)? onMessage,
  }) {
    List<DebateTeam> topTeams =
        ScoreManager.getTopTeams(tournament.teamsInTheTournament, tournament);
    List<Debater> topDebaters = ScoreManager.getTopDebaters(
        tournament.teamsInTheTournament, tournament);

    if (onTopPerformersRetrieved != null) {
      onTopPerformersRetrieved(topTeams, topDebaters);
    } else {
      print("🎉 Top Teams:");
      for (var team in topTeams) {
        print(
            "🏆 ${team.teamName} - Wins: ${team.teamWins}, Score: ${team.teamScore}");
      }

      print("\n🎖 Top Debaters:");
      for (var debater in topDebaters.take(5)) {
        print(
            "⭐ ${debater.name} - Score: ${debater.individualScore} | UserID: ${debater.userID}");
      }

      print("\nPress any key to continue...");
    }
  }

  static Future<TournamentStage> advanceSegment(
    Tournament tournament, {
    Function(String)? onMessage,
  }) async {
    if (tournament.currentSegment.value > TournamentStage.preliminary2.value) {
      String message = "Advancing to the next segment...";
      if (onMessage != null) {
        onMessage(message);
      } else {
        print(message);
      }
      showTopPerformers(
          tournament); // Show top teams and debaters before advancing
    }

    // If advances to Quarter, Semi, or Final, remove teams that did not qualify
    switch (tournament.currentSegment) {
      case TournamentStage.preliminary3:
        tournament.teamsInTheTournament = ScoreManager.getTopTeams(
            tournament.teamsInTheTournament, tournament,
            topN: 16);
        break;
      case TournamentStage.octaFinal:
        tournament.teamsInTheTournament = ScoreManager.getTopTeams(
            tournament.teamsInTheTournament, tournament,
            topN: 8);
        break;
      case TournamentStage.quarterFinal:
        tournament.teamsInTheTournament = ScoreManager.getTopTeams(
            tournament.teamsInTheTournament, tournament,
            topN: 4);
        break;
      case TournamentStage.semiFinal:
        tournament.teamsInTheTournament = ScoreManager.getTopTeams(
            tournament.teamsInTheTournament, tournament,
            topN: 2);
        break;
      default:
        break;
    }

    // Advance the tournament segment
    if (tournament.currentSegment.index < TournamentStage.values.length - 1) {
      TournamentStage newStage =
          TournamentStage.values[tournament.currentSegment.index + 1];
      tournament.currentSegment = newStage;
      String message = "Tournament advanced to: ${newStage.displayName}";
      if (onMessage != null) {
        onMessage(message);
      } else {
        print(message);
      }
    } else {
      String message = "The tournament has already reached the Final segment.";
      if (onMessage != null) {
        onMessage(message);
      } else {
        print(message);
      }
    }

    return tournament.currentSegment;
  }
}

import 'dart:io';
import 'debate_team.dart';

class DebateMatch {
  DebateTeam teamA, teamB;
  List<int> teamAScores, teamBScores;
  bool isCompleted;

  DebateMatch({
    required this.teamA,
    required this.teamB,
    this.teamAScores = const [0, 0, 0],
    this.teamBScores = const [0, 0, 0],
    this.isCompleted = false,
  });

  Future<void> submitScores(
      List<int> aScores, int aRebuttal, List<int> bScores, int bRebuttal,
      {Function(String)? onTieCallback}) async {
    if (aScores.length != 3 || bScores.length != 3) {
      throw ArgumentError("Each team must have exactly 3 debater scores.");
    }

    teamAScores = List.from(aScores);
    teamBScores = List.from(bScores);

    int teamATotal = aScores.fold(0, (sum, score) => sum + score) + aRebuttal;
    int teamBTotal = bScores.fold(0, (sum, score) => sum + score) + bRebuttal;

    // Update individual debater scores
    for (int i = 0; i < 3; i++) {
      teamA.teamMembers[i].increaseIndividualScore(aScores[i]);
      teamB.teamMembers[i].increaseIndividualScore(bScores[i]);
    }

    teamA.increaseTeamScore(teamATotal);
    teamB.increaseTeamScore(teamBTotal);

    if (teamATotal > teamBTotal) {
      teamA.teamWinsADebate();
      teamB.teamLosesADebate();
    } else if (teamBTotal > teamATotal) {
      teamB.teamWinsADebate();
      teamA.teamLosesADebate();
    } else {
      // Handle tie - in Flutter app, this would be handled by UI callback
      print("The scores are tied.");
      print("Team A: ${teamA.teamName}");
      print("Team B: ${teamB.teamName}");

      if (onTieCallback != null) {
        // For Flutter UI, use callback to handle tie
        onTieCallback("tie");
      } else {
        // For console/testing, use simple input
        print(
            "Enter the number of the team that wins (1 for Team A, 2 for Team B):");
        String? input = stdin.readLineSync();

        if (input == "1") {
          teamA.teamWinsADebate();
          teamB.teamLosesADebate();
        } else if (input == "2") {
          teamB.teamWinsADebate();
          teamA.teamLosesADebate();
        } else {
          print("Invalid input. Team A wins by default.");
          teamA.teamWinsADebate();
          teamB.teamLosesADebate();
        }
      }
    }

    isCompleted = true;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'teamA': teamA.toJson(),
      'teamB': teamB.toJson(),
      'teamAScores': teamAScores,
      'teamBScores': teamBScores,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory DebateMatch.fromJson(Map<String, dynamic> json) {
    return DebateMatch(
      teamA: DebateTeam.fromJson(json['teamA'] ?? {}),
      teamB: DebateTeam.fromJson(json['teamB'] ?? {}),
      teamAScores: List<int>.from(json['teamAScores'] ?? [0, 0, 0]),
      teamBScores: List<int>.from(json['teamBScores'] ?? [0, 0, 0]),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

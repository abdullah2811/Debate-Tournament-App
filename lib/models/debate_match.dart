import 'debate_team.dart';

class DebateMatch {
  DebateTeam teamA, teamB;
  List<int> teamAScores, teamBScores;
  bool isCompleted;
  int? venue;

  DebateMatch({
    required this.teamA,
    required this.teamB,
    this.teamAScores = const [0, 0, 0],
    this.teamBScores = const [0, 0, 0],
    this.isCompleted = false,
    this.venue,
  });

  void submitScores(List<int> scoresA, List<int> scoresB, int rebA, int rebB) {
    for (int i = 0; i < 3; i++) {
      teamA.teamMembers[i].increaseDebaterScore(scoresA[i]);
      teamB.teamMembers[i].increaseDebaterScore(scoresB[i]);
    }
    int totalA = scoresA[0] + scoresA[1] + scoresA[2] + rebA;
    int totalB = scoresB[0] + scoresB[1] + scoresB[2] + rebB;
    teamA.increaseTeamScore(totalA);
    teamB.increaseTeamScore(totalB);
    if (totalA > totalB) {
      teamA.teamWinsADebate();
      teamB.teamLosesADebate();
    } else if (totalB > totalA) {
      teamB.teamWinsADebate();
      teamA.teamLosesADebate();
    } else {
      throw Exception(
          "Check Tie: ${teamA.teamName} scores $totalA vs ${teamB.teamName} scores $totalB");
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
      'venue': venue,
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
      venue: json['venue'],
    );
  }
}

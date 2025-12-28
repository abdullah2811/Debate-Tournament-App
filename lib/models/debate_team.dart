import 'debater.dart';

class DebateTeam {
  int teamID;
  String teamName;
  List<dynamic> teamMembers; // Will contain Debater objects
  double teamScore;
  String teamStatus;
  int teamWins;
  int teamLosses;
  int teamPlayedGovernment;
  int teamPlayedOpposition;
  bool autoQualified = false;

  DebateTeam({
    required this.teamID,
    required this.teamName,
    required this.teamMembers,
    this.teamScore = 0.0,
    this.teamWins = 0,
    this.teamLosses = 0,
    this.teamStatus = 'notPlayed',
    this.teamPlayedGovernment = 0,
    this.teamPlayedOpposition = 0,
    this.autoQualified = false,
  });

  void increaseTeamScore(int score) {
    teamScore += score;
  }

  void teamWinsADebate() {
    teamStatus = 'win';
    teamWins++;
  }

  void teamLosesADebate() {
    teamStatus = 'lose';
    teamLosses++;
  }

  void updateTeamName(String newName) {
    teamName = newName;
  }

  void teamPlaysAsGovernment() {
    teamPlayedGovernment++;
  }

  void teamPlaysAsOpposition() {
    teamPlayedOpposition++;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'teamID': teamID,
      'teamMembers': teamMembers.map((member) {
        if (member is Debater) {
          return member.toJson();
        } else if (member is Map<String, dynamic>) {
          return member;
        }
        return member.toJson();
      }).toList(),
      'teamWins': teamWins,
      'teamLosses': teamLosses,
      'teamScore': teamScore,
      'teamStatus': teamStatus,
      'teamPlayedGovernment': teamPlayedGovernment,
      'teamPlayedOpposition': teamPlayedOpposition,
      'autoQualified': autoQualified,
    };
  }

  // Create from JSON
  factory DebateTeam.fromJson(Map<String, dynamic> json) {
    // Import Debater here when used
    return DebateTeam(
      teamID: json['teamID'] ?? 0,
      teamName: json['teamName'] ?? '',
      teamMembers: (json['teamMembers'] as List?)?.map((memberJson) {
            if (memberJson is Map<String, dynamic>) {
              return Debater.fromJson(memberJson);
            }
            return memberJson;
          }).toList() ??
          [],
      teamScore: (json['teamScore'] ?? 0.0).toDouble(),
      teamWins: json['teamWins'] ?? 0,
      teamLosses: json['teamLosses'] ?? 0,
      teamStatus: json['teamStatus'] ?? 'notPlayed',
      teamPlayedGovernment: json['teamPlayedGovernment'] ?? 0,
      teamPlayedOpposition: json['teamPlayedOpposition'] ?? 0,
      autoQualified: json['autoQualified'] ?? false,
    );
  }
}

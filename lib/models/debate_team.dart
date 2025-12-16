enum DebateTeamStatus {
  notPlayed,
  win,
  lose,
}

class DebateTeam {
  int teamID;
  String teamName;
  List<dynamic> teamMembers; // Will contain Debater objects
  double teamScore;
  DebateTeamStatus teamStatus;
  int teamWins;
  int teamLosses;
  int teamPlayedGovernment;
  int teamPlayedOpposition;

  DebateTeam({
    required this.teamID,
    required this.teamName,
    required this.teamMembers,
    this.teamScore = 0.0,
    this.teamWins = 0,
    this.teamLosses = 0,
    this.teamStatus = DebateTeamStatus.notPlayed,
    this.teamPlayedGovernment = 0,
    this.teamPlayedOpposition = 0,
  });

  void increaseTeamScore(int score) {
    teamScore += score;
  }

  void teamWinsADebate() {
    teamStatus = DebateTeamStatus.win;
    teamWins++;
  }

  void teamLosesADebate() {
    teamStatus = DebateTeamStatus.lose;
    teamLosses++;
  }

  void updateTeamName(String newName) {
    teamName = newName;
  }

  void updateTeamMembers(List<dynamic> newMembers) {
    teamMembers = newMembers;
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
      'teamMembers': teamMembers.map((member) => member.toJson()).toList(),
      'teamWins': teamWins,
      'teamLosses': teamLosses,
      'teamScore': teamScore,
      'teamStatus': teamStatus.index,
      'teamPlayedGovernment': teamPlayedGovernment,
      'teamPlayedOpposition': teamPlayedOpposition,
    };
  }

  // Create from JSON
  factory DebateTeam.fromJson(Map<String, dynamic> json) {
    // Import Debater here when used
    return DebateTeam(
      teamID: json['teamID'] ?? 0,
      teamName: json['teamName'] ?? '',
      teamMembers: (json['teamMembers'] as List?)
              ?.map((memberJson) =>
                  memberJson) // Will need proper Debater.fromJson when imported
              .toList() ??
          [],
      teamScore: (json['teamScore'] ?? 0.0).toDouble(),
      teamWins: json['teamWins'] ?? 0,
      teamLosses: json['teamLosses'] ?? 0,
      teamStatus: DebateTeamStatus.values[json['teamStatus'] ?? 0],
      teamPlayedGovernment: json['teamPlayedGovernment'] ?? 0,
      teamPlayedOpposition: json['teamPlayedOpposition'] ?? 0,
    );
  }
}

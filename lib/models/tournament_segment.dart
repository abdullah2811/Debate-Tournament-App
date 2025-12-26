class TournamentSegment {
  String segmentName;
  int segmentID;
  List<dynamic>? teamsInThisSegment; // Will contain DebateTeam objects
  int numberOfTeamsInSegment;
  int numberOfTeamsAutoQualifiedForNextRound = 0;

  TournamentSegment({
    required this.segmentName,
    required this.segmentID,
    this.teamsInThisSegment,
    this.numberOfTeamsInSegment = 0,
    this.numberOfTeamsAutoQualifiedForNextRound = 0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'segmentName': segmentName,
      'segmentID': segmentID,
      // Support both model objects and raw maps already coming from Firestore
      'teamsInThisSegment': teamsInThisSegment!.map((team) {
        if (team is Map<String, dynamic>) {
          return team;
        }
        try {
          return team.toJson();
        } catch (_) {
          return team;
        }
      }).toList(),
      'numberOfTeamsInSegment': numberOfTeamsInSegment,
      'numberOfTeamsAutoQualifiedForNextRound':
          numberOfTeamsAutoQualifiedForNextRound,
    };
  }

  // Create from JSON
  factory TournamentSegment.fromJson(Map<String, dynamic> json) {
    return TournamentSegment(
      segmentName: json['segmentName'] ?? '',
      segmentID: json['segmentID'] ?? 0,
      teamsInThisSegment: (json['teamsInThisSegment'] as List?)
              ?.map((teamJson) => teamJson)
              .toList() ??
          [],
      numberOfTeamsInSegment: json['numberOfTeamsInSegment'] ?? 0,
      numberOfTeamsAutoQualifiedForNextRound:
          json['numberOfTeamsAutoQualifiedForNextRound'] ?? 0,
    );
  }
}

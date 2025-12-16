// Enum for tournament stages with explicit values
enum TournamentStage {
  preliminary1,
  preliminary2,
  preliminary3,
  octaFinal,
  quarterFinal,
  semiFinal,
  finalStage,
}

extension TournamentStageExtension on TournamentStage {
  int get value {
    switch (this) {
      case TournamentStage.preliminary1: return 1;
      case TournamentStage.preliminary2: return 2;
      case TournamentStage.preliminary3: return 3;
      case TournamentStage.octaFinal: return 4;
      case TournamentStage.quarterFinal: return 5;
      case TournamentStage.semiFinal: return 6;
      case TournamentStage.finalStage: return 7;
    }
  }

  String get displayName {
    switch (this) {
      case TournamentStage.preliminary1: return 'Preliminary 1';
      case TournamentStage.preliminary2: return 'Preliminary 2';
      case TournamentStage.preliminary3: return 'Preliminary 3';
      case TournamentStage.octaFinal: return 'Octa Final';
      case TournamentStage.quarterFinal: return 'Quarter Final';
      case TournamentStage.semiFinal: return 'Semi Final';
      case TournamentStage.finalStage: return 'Final';
    }
  }
}

// Represents a segment (stage) of the tournament
class TournamentSegment {
  String segmentName;
  int segmentID;
  List<dynamic> teamsInThisSegment; // Will contain DebateTeam objects
  int numberOfTeamsInSegment;

  TournamentSegment({
    required this.segmentName,
    required this.segmentID,
    this.teamsInThisSegment = const [],
    this.numberOfTeamsInSegment = 0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'segmentName': segmentName,
      'segmentID': segmentID,
      'teamsInThisSegment': teamsInThisSegment.map((team) => team.toJson()).toList(),
      'numberOfTeamsInSegment': numberOfTeamsInSegment,
    };
  }

  // Create from JSON
  factory TournamentSegment.fromJson(Map<String, dynamic> json) {
    return TournamentSegment(
      segmentName: json['segmentName'] ?? '',
      segmentID: json['segmentID'] ?? 0,
      teamsInThisSegment: (json['teamsInThisSegment'] as List?)
          ?.map((teamJson) => teamJson)
          .toList() ?? [],
      numberOfTeamsInSegment: json['numberOfTeamsInSegment'] ?? 0,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_team.dart';
import 'tournament_segment.dart';
import 'debate_match.dart';

enum TournamentFormat {
  asianParliamentary,
  britishParliamentary,
  lincolnDouglas,
  policyDebate,
  publicForum,
  studentCongress,
}

class Tournament {
  String tournamentName;
  String tournamentID;
  String tournamentClubName;
  String? tournamentLocation;
  String? tournamentDescription;
  DateTime tournamentStartingDate;
  DateTime tournamentEndingDate;
  int numberOfTeamsInTournament = 0;
  int? maxTeams;
  double? prizePool;
  TournamentFormat tournamentFormat;
  TournamentStage currentSegment;
  String? createdByUserID;
  DateTime? createdAt;
  List<DebateTeam>? teamsInTheTournament;
  List<DebateMatch>? currentMatches;

  Tournament({
    required this.tournamentName,
    required this.tournamentID,
    required this.tournamentClubName,
    required this.tournamentStartingDate,
    required this.tournamentEndingDate,
    this.tournamentLocation,
    this.tournamentDescription,
    this.numberOfTeamsInTournament = 0,
    this.maxTeams,
    this.prizePool,
    this.tournamentFormat = TournamentFormat.britishParliamentary,
    this.currentSegment = TournamentStage.preliminary1,
    this.createdByUserID,
    this.createdAt,
    this.teamsInTheTournament,
    this.currentMatches,
  });

  CollectionReference<Map<String, dynamic>> get _tournamentsCollection =>
      FirebaseFirestore.instance.collection('tournaments');

  // Save tournament to Firestore
  Future<void> saveTournament() async {
    try {
      await _tournamentsCollection.doc(tournamentID).set(toJson());
    } catch (e) {
      throw Exception('Error saving tournament: $e');
    }
  }

  // Update tournament in Firestore
  Future<void> updateTournament() async {
    try {
      await _tournamentsCollection.doc(tournamentID).update(toJson());
    } catch (e) {
      throw Exception('Error updating tournament: $e');
    }
  }

  // Get tournament from Firestore
  static Future<Tournament?> getTournament(String tournamentID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentID)
          .get();
      if (doc.exists) {
        return Tournament.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting tournament: $e');
    }
  }

  void addTeam(tournamentId, String teamName, String debaterName1,
      String debaterName2, String debaterName3) {
    // ADD LOGIC FOR ADDING A TEAM
  }

  void removeTeam(tournamentId, String teamName, String debaterName1,
      String debaterName2, String debaterName3) {
    // ADD LOGIC FOR REMOVING A TEAM
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'tournamentName': tournamentName,
      'tournamentID': tournamentID,
      'tournamentClubName': tournamentClubName,
      'tournamentLocation': tournamentLocation,
      'tournamentDescription': tournamentDescription,
      'tournamentStartingDate': tournamentStartingDate.toIso8601String(),
      'tournamentEndingDate': tournamentEndingDate.toIso8601String(),
      'currentSegment': currentSegment.index,
      'numberOfTeamsInTournament': numberOfTeamsInTournament,
      'maxTeams': maxTeams,
      'prizePool': prizePool,
      'tournamentFormat': tournamentFormat.index,
      'createdByUserID': createdByUserID,
      'createdAt': createdAt?.toIso8601String(),
      'teamsInTheTournament':
          teamsInTheTournament?.map((team) => team.toJson()).toList(),
      'currentMatches': currentMatches?.map((match) => match.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return Tournament(
      tournamentClubName: json['tournamentClubName'] ?? '',
      tournamentName: json['tournamentName'] ?? '',
      tournamentID: json['tournamentID'] ?? '',
      tournamentLocation: json['tournamentLocation'],
      tournamentDescription: json['tournamentDescription'],
      tournamentStartingDate:
          parseDate(json['tournamentStartingDate']) ?? DateTime.now(),
      tournamentEndingDate:
          parseDate(json['tournamentEndingDate']) ?? DateTime.now(),
      currentSegment: TournamentStage.values[json['currentSegment'] ?? 0],
      numberOfTeamsInTournament: json['numberOfTeamsInTournament'] ?? 0,
      maxTeams: json['maxTeams'],
      prizePool: json['prizePool']?.toDouble(),
      tournamentFormat: TournamentFormat.values[json['tournamentFormat'] ?? 1],
      createdByUserID: json['createdByUserID'],
      createdAt: parseDate(json['createdAt']),
      teamsInTheTournament: (json['teamsInTheTournament'] as List?)
          ?.map((teamJson) => DebateTeam.fromJson(teamJson))
          .toList(),
      currentMatches: (json['currentMatches'] as List?)
          ?.map((matchJson) => DebateMatch.fromJson(matchJson))
          .toList(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_team.dart';
import 'debate_match.dart';
import 'debater.dart';

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
  String currentSegment;
  String? createdByUserID;
  DateTime? createdAt;
  List<Debater>? debatersInTheTournament;
  List<DebateTeam>? teamsInTheTournament;
  List<DebateMatch>? currentMatches;
  bool teamAdditionClosed = false;

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
    this.tournamentFormat = TournamentFormat.asianParliamentary,
    this.currentSegment = '1st Tab Round',
    this.createdByUserID,
    this.createdAt,
    this.debatersInTheTournament,
    this.teamsInTheTournament,
    this.currentMatches,
    this.teamAdditionClosed = false,
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

  void addDebater(Debater debater) {
    debatersInTheTournament ??= [];
    debatersInTheTournament!.add(debater);
    updateTournament();
  }

  void removeDebater(Debater debater) {
    debatersInTheTournament ??= [];
    debatersInTheTournament!
        .removeWhere((d) => d.debaterID == debater.debaterID);
    updateTournament();
  }

  void addTeam(Tournament tournament, DebateTeam team) {
    final newTeam = team;
    tournament.teamsInTheTournament ??= [];
    tournament.teamsInTheTournament!.add(newTeam);
    tournament.numberOfTeamsInTournament++;
    tournament.updateTournament();
    //Add the debaters to the debaters list
    for (var debater in team.teamMembers) {
      tournament.addDebater(debater);
    }
  }

  void removeTeam(Tournament tournament, DebateTeam team) {
    tournament.teamsInTheTournament ??= [];
    tournament.teamsInTheTournament!.removeWhere((t) =>
        t.teamName == team.teamName &&
        t.teamMembers.length == 3 &&
        t.teamMembers[0].name == team.teamMembers[0].name &&
        t.teamMembers[1].name == team.teamMembers[1].name &&
        t.teamMembers[2].name == team.teamMembers[2].name);
    tournament.numberOfTeamsInTournament--;
    tournament.updateTournament();
    //Remove the debaters from the debaters list
    tournament.debatersInTheTournament ??= [];
    tournament.debatersInTheTournament!.removeWhere((debater) =>
        debater.debaterID == team.teamMembers[0].debaterID ||
        debater.debaterID == team.teamMembers[1].debaterID ||
        debater.debaterID == team.teamMembers[2].debaterID);
    tournament.updateTournament();
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
      'currentSegment': currentSegment,
      'numberOfTeamsInTournament': numberOfTeamsInTournament,
      'maxTeams': maxTeams,
      'prizePool': prizePool,
      'tournamentFormat': tournamentFormat.index,
      'createdByUserID': createdByUserID,
      'createdAt': createdAt?.toIso8601String(),
      'debatersInTheTournament':
          debatersInTheTournament?.map((debater) => debater.toJson()).toList(),
      'teamsInTheTournament':
          teamsInTheTournament?.map((team) => team.toJson()).toList(),
      'currentMatches': currentMatches?.map((match) => match.toJson()).toList(),
      'teamAdditionClosed': teamAdditionClosed,
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
      currentSegment: json['currentSegment'] ?? '1st Tab Round',
      numberOfTeamsInTournament: json['numberOfTeamsInTournament'] ?? 0,
      maxTeams: json['maxTeams'],
      prizePool: json['prizePool']?.toDouble(),
      tournamentFormat: TournamentFormat.values[json['tournamentFormat'] ?? 1],
      createdByUserID: json['createdByUserID'],
      createdAt: parseDate(json['createdAt']),
      debatersInTheTournament: (json['debatersInTheTournament'] as List?)
          ?.map((debaterJson) => Debater.fromJson(debaterJson))
          .toList(),
      teamsInTheTournament: (json['teamsInTheTournament'] as List?)
          ?.map((teamJson) => DebateTeam.fromJson(teamJson))
          .toList(),
      currentMatches: (json['currentMatches'] as List?)
          ?.map((matchJson) => DebateMatch.fromJson(matchJson))
          .toList(),
      // Defaults to false if missing
      teamAdditionClosed: json['teamAdditionClosed'] == true,
    );
  }
}

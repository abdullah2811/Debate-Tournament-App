import 'dart:io';
import 'debate_team.dart';
import 'debater.dart';
import 'tournament_segment.dart';
import 'debate_match.dart';

class Tournament {
  String clubName;
  String tournamentName;
  String tournamentYear;
  TournamentStage currentSegment;
  int numberOfTeamsInTournament;
  List<DebateTeam> teamsInTheTournament;
  List<DebateMatch> currentMatches;

  Tournament({
    required this.clubName,
    required this.tournamentName,
    required this.tournamentYear,
    this.currentSegment = TournamentStage.preliminary1,
    this.numberOfTeamsInTournament = 0,
    List<DebateTeam>? teamsInTheTournament,
    List<DebateMatch>? currentMatches,
  })  : teamsInTheTournament = teamsInTheTournament ?? [],
        currentMatches = currentMatches ?? [];

  static Future<void> addTeam(
    Tournament tournament, {
    Function(String)? onSuccess,
    Function(String)? onError,
    Future<String> Function(String)? inputCallback,
  }) async {
    try {
      String teamName;
      if (inputCallback != null) {
        teamName = await inputCallback("Enter team name:");
      } else {
        print("Enter team name:");
        teamName = stdin.readLineSync() ?? '';
      }

      List<Debater> members = [];
      for (int i = 1; i <= 3; i++) {
        String name, userID;
        if (inputCallback != null) {
          name = await inputCallback("Enter details for Debater $i - Name:");
          userID = await inputCallback("User ID:");
        } else {
          print("Enter details for Debater $i:");
          print("Name:");
          name = stdin.readLineSync() ?? '';
          print("User ID:");
          userID = stdin.readLineSync() ?? '';
        }
        members.add(Debater(debaterID: i, name: name, userID: userID));
      }

      int teamID = tournament.teamsInTheTournament.length + 1;
      DebateTeam team = DebateTeam(
        teamID: teamID,
        teamName: teamName,
        teamMembers: members,
      );

      tournament.teamsInTheTournament.add(team);

      if (onSuccess != null) {
        onSuccess("Team added successfully.");
      } else {
        print("Team added successfully. Press any key to continue.");
      }
    } catch (e) {
      if (onError != null) {
        onError("Error adding team: $e");
      } else {
        print("Error adding team: $e");
      }
    }
  }

  static Future<void> removeTeam(
    Tournament tournament, {
    Function(String)? onSuccess,
    Function(String)? onError,
    Future<String> Function(String)? inputCallback,
  }) async {
    try {
      String name;
      if (inputCallback != null) {
        name = await inputCallback("Enter team name to remove:");
      } else {
        print("Enter team name to remove:");
        name = stdin.readLineSync() ?? '';
      }

      DebateTeam? team =
          tournament.teamsInTheTournament.cast<DebateTeam?>().firstWhere(
                (t) => t?.teamName.toLowerCase() == name.toLowerCase(),
                orElse: () => null,
              );

      if (team != null) {
        tournament.teamsInTheTournament.remove(team);
        if (onSuccess != null) {
          onSuccess("Team removed successfully.");
        } else {
          print("Team removed successfully.");
        }
      } else {
        if (onError != null) {
          onError("Team not found.");
        } else {
          print("Team not found.");
        }
      }
    } catch (e) {
      if (onError != null) {
        onError("Error removing team: $e");
      } else {
        print("Error removing team: $e");
      }
    }
  }

  static void viewTeams(Tournament tournament,
      {Function(List<DebateTeam>)? onTeamsRetrieved}) {
    if (tournament.teamsInTheTournament.isEmpty) {
      if (onTeamsRetrieved != null) {
        onTeamsRetrieved([]);
      } else {
        print("No teams added yet.");
      }
    } else {
      if (onTeamsRetrieved != null) {
        onTeamsRetrieved(tournament.teamsInTheTournament);
      } else {
        print("Teams in the tournament:");
        for (var team in tournament.teamsInTheTournament) {
          print(
              "${team.teamID}: ${team.teamName} | Score: ${team.teamScore} | Wins: ${team.teamWins}");
        }
      }
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'clubName': clubName,
      'tournamentName': tournamentName,
      'tournamentYear': tournamentYear,
      'currentSegment': currentSegment.index,
      'numberOfTeamsInTournament': numberOfTeamsInTournament,
      'teamsInTheTournament':
          teamsInTheTournament.map((team) => team.toJson()).toList(),
      'currentMatches': currentMatches.map((match) => match.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      clubName: json['clubName'] ?? '',
      tournamentName: json['tournamentName'] ?? '',
      tournamentYear: json['tournamentYear'] ?? '',
      currentSegment: TournamentStage.values[json['currentSegment'] ?? 0],
      numberOfTeamsInTournament: json['numberOfTeamsInTournament'] ?? 0,
      teamsInTheTournament: (json['teamsInTheTournament'] as List?)
              ?.map((teamJson) => DebateTeam.fromJson(teamJson))
              .toList() ??
          [],
      currentMatches: (json['currentMatches'] as List?)
              ?.map((matchJson) => DebateMatch.fromJson(matchJson))
              .toList() ??
          [],
    );
  }
}

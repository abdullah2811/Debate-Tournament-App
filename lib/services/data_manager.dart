import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/tournament.dart';
import '../models/debate_team.dart';
import '../models/debater.dart';
import '../models/debate_match.dart';

class DataManager {
  static late String tournamentRecordsFolderPath;
  static late String filePath;

  static void initialize() {
    // Initialize paths for Flutter app
    String baseDir = Directory.current.path;
    tournamentRecordsFolderPath = path.join(baseDir, 'tournament_records');
    filePath = path.join(baseDir, 'tournament_docs');
  }

  static Future<void> saveTournamentToJson(Tournament tournament) async {
    try {
      await Directory(tournamentRecordsFolderPath).create(recursive: true);

      String fileName =
          '${tournament.tournamentName}_${tournament.tournamentYear}.json';
      String fullPath = path.join(tournamentRecordsFolderPath, fileName);

      File file = File(fullPath);
      String jsonString = jsonEncode(tournament.toJson());

      await file.writeAsString(jsonString);
      print('Tournament saved to: $fullPath');
    } catch (e) {
      print('Error saving tournament: $e');
    }
  }

  static Future<void> saveMatchupToJson(
      List<DebateMatch> matchups, Tournament tournament) async {
    try {
      await Directory(filePath).create(recursive: true);

      Map<String, dynamic> matchupData = {
        'tournamentName': tournament.tournamentName,
        'tournamentYear': tournament.tournamentYear,
        'clubName': tournament.clubName,
        'currentSegment': tournament.currentSegment.index,
        'matchups': matchups.map((match) => match.toJson()).toList(),
      };

      String fileName =
          'Matchups_${tournament.tournamentName}_${tournament.tournamentYear}_${tournament.currentSegment.name}.json';
      String fullPath = path.join(filePath, fileName);

      File file = File(fullPath);
      String jsonString = jsonEncode(matchupData);

      await file.writeAsString(jsonString);
      print('Matchup data exported to: $fullPath');
    } catch (e) {
      print('Error saving matchups: $e');
    }
  }

  static Future<void> saveTopDebatersToJson(
      List<Debater> topDebaters, Tournament tournament) async {
    try {
      await Directory(filePath).create(recursive: true);

      Map<String, dynamic> data = {
        'tournamentName': tournament.tournamentName,
        'tournamentYear': tournament.tournamentYear,
        'clubName': tournament.clubName,
        'currentSegment': tournament.currentSegment.index,
        'topDebaters': topDebaters.map((debater) => debater.toJson()).toList(),
      };

      String fileName =
          'Top_Debaters_${tournament.tournamentName}_${tournament.tournamentYear}_${tournament.currentSegment.name}.json';
      String fullPath = path.join(filePath, fileName);

      File file = File(fullPath);
      String jsonString = jsonEncode(data);

      await file.writeAsString(jsonString);
      print('Top debaters data exported to: $fullPath');
    } catch (e) {
      print('Error saving top debaters: $e');
    }
  }

  static Future<void> saveTopTeamsToJson(
      List<DebateTeam> topTeams, Tournament tournament) async {
    try {
      await Directory(filePath).create(recursive: true);

      Map<String, dynamic> data = {
        'tournamentName': tournament.tournamentName,
        'tournamentYear': tournament.tournamentYear,
        'clubName': tournament.clubName,
        'currentSegment': tournament.currentSegment.index,
        'topTeams': topTeams.map((team) => team.toJson()).toList(),
      };

      String fileName =
          'Top_Teams_${tournament.tournamentName}_${tournament.tournamentYear}_${tournament.currentSegment.name}.json';
      String fullPath = path.join(filePath, fileName);

      File file = File(fullPath);
      String jsonString = jsonEncode(data);

      await file.writeAsString(jsonString);
      print('Top teams data exported to: $fullPath');
    } catch (e) {
      print('Error saving top teams: $e');
    }
  }

  static Future<Tournament?> loadTournamentFromJson(String filePath) async {
    try {
      File file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return null;
      }

      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      return Tournament.fromJson(jsonData);
    } catch (e) {
      print('Error loading tournament from $filePath: $e');
      return null;
    }
  }

  static Future<List<Tournament>> loadTournamentsFromFolder() async {
    List<Tournament> tournaments = [];

    try {
      Directory directory = Directory(tournamentRecordsFolderPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        return tournaments;
      }

      await for (FileSystemEntity entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          Tournament? tournament = await loadTournamentFromJson(entity.path);
          if (tournament != null) {
            tournaments.add(tournament);
          }
        }
      }
    } catch (e) {
      print('Error loading tournaments from folder: $e');
    }

    return tournaments;
  }

  static Future<List<DebateMatch>> loadMatchupsFromJson(
      Tournament tournament) async {
    try {
      String fileName =
          'Matchups_${tournament.tournamentName}_${tournament.tournamentYear}_${tournament.currentSegment.name}.json';
      String fullPath = path.join(filePath, fileName);

      File file = File(fullPath);
      if (!await file.exists()) {
        return <DebateMatch>[];
      }

      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      List<DebateMatch> matches = [];
      List<dynamic> matchupsJson = jsonData['matchups'] ?? [];

      for (var matchJson in matchupsJson) {
        matches.add(DebateMatch.fromJson(matchJson));
      }

      return matches;
    } catch (e) {
      print('Error loading matchups: $e');
      return <DebateMatch>[];
    }
  }

  // Utility method to export data as CSV format (for compatibility with Excel)
  static Future<void> exportTournamentToCsv(Tournament tournament) async {
    try {
      await Directory(tournamentRecordsFolderPath).create(recursive: true);

      String fileName =
          '${tournament.tournamentName}_${tournament.tournamentYear}.csv';
      String fullPath = path.join(tournamentRecordsFolderPath, fileName);

      StringBuffer csv = StringBuffer();

      // Header
      csv.writeln('Tournament Name,${tournament.tournamentName}');
      csv.writeln('Year,${tournament.tournamentYear}');
      csv.writeln('Club,${tournament.clubName}');
      csv.writeln(
          'Current Segment,${tournament.currentSegment.toString().split('.').last}');
      csv.writeln('');

      // Data headers
      csv.writeln(
          'Team ID,Team Name,Team Score,Team Wins,Team Losses,Team Status,Debater ID,Debater Name,Department,Individual Score');

      // Data rows
      for (var team in tournament.teamsInTheTournament) {
        csv.writeln(
            '${team.teamID},${team.teamName},${team.teamScore},${team.teamWins},${team.teamLosses},${team.teamStatus.name},,,,');

        for (var debater in team.teamMembers.cast<Debater>()) {
          csv.writeln(
              ',,,,,,"${debater.debaterID}","${debater.name}","${debater.userID}",${debater.individualScore}');
        }
      }

      File file = File(fullPath);
      await file.writeAsString(csv.toString());
      print('Tournament exported to CSV: $fullPath');
    } catch (e) {
      print('Error exporting to CSV: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class App {
  String appName = 'DebateTournamentApp';
  String appVersion = '1.0.0';
  String developer = 'Abdullah';
  String contactEmail = 'abdullahiar2811@gmail.com';
  int tournamentsCreated = 0;
  int teamsHandled = 0;
  int debatersHandled = 0;
  int usersRegistered = 0;
  List<String> notifications = [];

  App({
    this.appName = 'DebateTournamentApp',
    this.appVersion = '1.0.0',
    this.developer = 'Abdullah',
    this.contactEmail = 'abdullahiar2811@gmail.com',
    this.tournamentsCreated = 0,
    this.teamsHandled = 0,
    this.debatersHandled = 0,
    this.usersRegistered = 0,
    this.notifications = const [],
  });

  static const String appStatsDocId = 'app_stats';
  static const String collectionName = 'app_statistics';

  CollectionReference<Map<String, dynamic>> get _appStatsCollection =>
      FirebaseFirestore.instance.collection(collectionName);
  // Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'developer': developer,
      'contactEmail': contactEmail,
      'tournamentsCreated': tournamentsCreated,
      'teamsHandled': teamsHandled,
      'debatersHandled': debatersHandled,
      'usersRegistered': usersRegistered,
      'notifications': notifications,
    };
  }

  // Create from JSON
  factory App.fromJson(Map<String, dynamic> json) {
    return App()
      ..appName = json['appName'] ?? 'DebateTournamentApp'
      ..appVersion = json['appVersion'] ?? '1.0.0'
      ..developer = json['developer'] ?? 'Abdullah'
      ..contactEmail = json['contactEmail'] ?? 'abdullahiar2811@gmail.com'
      ..tournamentsCreated = json['tournamentsCreated'] ?? 0
      ..teamsHandled = json['teamsHandled'] ?? 0
      ..debatersHandled = json['debatersHandled'] ?? 0
      ..usersRegistered = json['usersRegistered'] ?? 0
      ..notifications = List<String>.from(json['notifications'] ?? []);
  }

  // Fetch App stats from Firestore
  static Future<App> fetchAppStats() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(appStatsDocId)
          .get();

      if (doc.exists) {
        return App.fromJson(doc.data()!);
      } else {
        // If document doesn't exist, create it with default values
        final newApp = App();
        await newApp.saveAppStats();
        return newApp;
      }
    } catch (e) {
      throw Exception('Error fetching app stats: $e');
    }
  }

  // Save App stats to Firestore
  Future<void> saveAppStats() async {
    try {
      await _appStatsCollection.doc(appStatsDocId).set(toJson());
    } catch (e) {
      throw Exception('Error saving app stats: $e');
    }
  }

  // Increment tournaments created
  static Future<void> incrementTournamentsCreated() async {
    try {
      final app = await fetchAppStats();
      app.tournamentsCreated++;
      await app.saveAppStats();
    } catch (e) {
      throw Exception('Error incrementing tournaments: $e');
    }
  }

  // Increment teams and debaters (when team addition is locked)
  static Future<void> incrementTeamsAndDebaters(
      int teamCount, int debaterCount) async {
    try {
      final app = await fetchAppStats();
      app.teamsHandled += teamCount;
      app.debatersHandled += debaterCount;
      await app.saveAppStats();
    } catch (e) {
      throw Exception('Error incrementing teams and debaters: $e');
    }
  }

  // Increment users registered
  static Future<void> incrementUsersRegistered() async {
    try {
      final app = await fetchAppStats();
      app.usersRegistered++;
      await app.saveAppStats();
    } catch (e) {
      throw Exception('Error incrementing users: $e');
    }
  }
}

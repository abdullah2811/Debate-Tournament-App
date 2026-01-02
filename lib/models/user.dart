import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'tournament.dart';

class User {
  String userID;
  String name;
  String email;
  String password;
  String? clubName;
  String? phoneNumber;
  String? address;
  DateTime? memberSince;
  List<Tournament> tournamentsRunByUser = [];

  User(
      {required this.name,
      required this.userID,
      required this.email,
      this.password = '',
      this.clubName,
      this.phoneNumber,
      this.address,
      this.memberSince,
      this.tournamentsRunByUser = const []});

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      FirebaseFirestore.instance.collection('users');

  Future<void> updateUserID(String newUserID) async {
    if (newUserID.trim().isEmpty || newUserID == userID) {
      return;
    }

    final oldRef = _usersCollection.doc(userID);
    final newRef = _usersCollection.doc(newUserID);
    final snapshot = await oldRef.get();
    final data = snapshot.data();

    if (data == null) {
      userID = newUserID;
      return;
    }

    data['userID'] = newUserID;

    await FirebaseFirestore.instance.runTransaction((txn) async {
      txn.set(newRef, data);
      txn.delete(oldRef);
    });

    userID = newUserID;
  }

  Future<void> updateName(String newName) async {
    name = newName;
    await _usersCollection.doc(userID).update({'name': newName});
  }

  Future<void> updateEmail(String newEmail) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }

    email = newEmail;
    await _usersCollection.doc(userID).update({'email': newEmail});
  }

  Future<void> updateClubName(String? newClubName) async {
    clubName = newClubName;
    await _usersCollection.doc(userID).update({'clubName': newClubName});
  }

  Future<void> updatePassword(String newPassword) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }

    password = newPassword;
  }

  Future<void> updatePhoneNumber(String? newPhoneNumber) async {
    phoneNumber = newPhoneNumber;
    await _usersCollection.doc(userID).update({'phoneNumber': newPhoneNumber});
  }

  Future<void> updateAddress(String? newAddress) async {
    address = newAddress;
    await _usersCollection.doc(userID).update({'address': newAddress});
  }

  Future<void> updateTournamentsRunByUser(Tournament newTournament) async {
    tournamentsRunByUser.add(newTournament);
    await _usersCollection.doc(userID).update({
      'tournamentsRunByUser':
          tournamentsRunByUser.map((t) => t.tournamentID).toList(),
    });
  }

  // Search for users by userID
  static Future<List<User>> searchUsersByID(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) {
        return [];
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userID', isGreaterThanOrEqualTo: searchQuery.toLowerCase())
          .where('userID', isLessThanOrEqualTo: '${searchQuery.toLowerCase()}\uf8ff')
          .get();

      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  // Get a single user by userID
  static Future<User?> getUserByID(String userID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'clubName': clubName,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'memberSince': memberSince?.toIso8601String(),
      'tournamentsRunByUser':
          tournamentsRunByUser.map((t) => t.tournamentID).toList(),
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parsedMemberSince;
    if (json['memberSince'] != null) {
      if (json['memberSince'] is Timestamp) {
        parsedMemberSince = (json['memberSince'] as Timestamp).toDate();
      } else if (json['memberSince'] is String) {
        parsedMemberSince = DateTime.tryParse(json['memberSince'] as String);
      }
    }

    return User(
      userID: json['userID'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      clubName: json['clubName'],
      password: json['password'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      memberSince: parsedMemberSince,
      tournamentsRunByUser: [],
    );
  }
}

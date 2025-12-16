class User {
  String userID;
  String name;
  String email;

  User({
    required this.userID,
    required this.name,
    required this.email,
  });

  void updateName(String newName) {
    name = newName;
  }

  void updateEmail(String newEmail) {
    email = newEmail;
  }

  void updateUserID(String newUserID) {
    //If new userID is valid, update it     LOGIC SHOULD BE ADDED HERE
    userID = newUserID;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

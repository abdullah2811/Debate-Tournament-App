class Debater {
  int debaterID;
  String name;
  String? userID;
  double individualScore;

  Debater({
    required this.debaterID,
    required this.name,
    this.userID = '',
    this.individualScore = 0.0,
  });

  void increaseIndividualScore(int score) {
    individualScore += score;
  }

  void updateName(String newName) {
    name = newName;
  }

  void updateUserID(String newUserID) {
    userID = newUserID;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'debaterID': debaterID,
      'name': name,
      'userID': userID,
      'individualScore': individualScore,
    };
  }

  // Create from JSON
  factory Debater.fromJson(Map<String, dynamic> json) {
    return Debater(
      debaterID: json['debaterID'] ?? 0,
      name: json['name'] ?? '',
      userID: json['userID'] ?? '',
      individualScore: (json['individualScore'] ?? 0.0).toDouble(),
    );
  }
}

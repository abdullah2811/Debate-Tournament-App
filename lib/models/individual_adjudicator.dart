class IndividualAdjudicator {
  int individualAdjudicatorID;
  String name;
  String departmentName;
  double individualScore;

  IndividualAdjudicator({
    required this.individualAdjudicatorID,
    required this.name,
    required this.departmentName,
    this.individualScore = 0.0,
  });

  void increaseIndividualScore(int score) {
    individualScore += score;
  }

  void updateName(String newName) {
    name = newName;
  }

  void updateDepartment(String newDept) {
    departmentName = newDept;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'individualAdjudicatorID': individualAdjudicatorID,
      'name': name,
      'departmentName': departmentName,
      'individualScore': individualScore,
    };
  }

  // Create from JSON
  factory IndividualAdjudicator.fromJson(Map<String, dynamic> json) {
    return IndividualAdjudicator(
      individualAdjudicatorID: json['individualAdjudicatorID'] ?? 0,
      name: json['name'] ?? '',
      departmentName: json['departmentName'] ?? '',
      individualScore: (json['individualScore'] ?? 0.0).toDouble(),
    );
  }
}

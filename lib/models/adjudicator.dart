class Adjudicator {
  int adjudicatorID;
  String name;

  Adjudicator({
    required this.adjudicatorID,
    required this.name,
  });

  void updateName(String newName) {
    name = newName;
  }
}

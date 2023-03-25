class Question {
  final String name;
  final String type;
  final String title;
  final String questionType;
  final String sectionHint;

  dynamic possibleValues;
  dynamic conditionalQuestions;
  dynamic response;

  Question({
    required this.name,
    required this.sectionHint,
    required this.type,
    required this.title,
    required this.questionType,
    this.possibleValues,
    this.response,
    this.conditionalQuestions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          title == other.title &&
          questionType == other.questionType &&
          sectionHint == other.sectionHint &&
          possibleValues == other.possibleValues &&
          conditionalQuestions == other.conditionalQuestions &&
          response == other.response;

  @override
  int get hashCode => Object.hashAll([
        name,
        type,
        title,
        questionType,
        sectionHint,
        possibleValues,
        conditionalQuestions,
        response,
      ]);

  @override
  String toString() {
    return 'Question{title: $name , $questionType}';
  }
}
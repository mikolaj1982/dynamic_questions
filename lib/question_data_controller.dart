import 'package:conditional_questions_simplified/question.dart';
import 'package:conditional_questions_simplified/question_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionDataList {
  List<QuestionData> data;

  QuestionDataList({
    required this.data,
  });
}

class QuestionDataListNotifier extends StateNotifier<QuestionDataList> {
  QuestionDataListNotifier() : super(QuestionDataList(data: []));

  void updateData(List<QuestionData> newData) {
    state = state.copyWith(data: newData);
  }
}

extension QuestionDataListExtension on QuestionDataList {
  QuestionDataList copyWith({List<QuestionData>? data}) {
    return QuestionDataList(data: data ?? this.data);
  }
}

class AddQuestionsNotifier extends StateNotifier<List<Question>> {
  AddQuestionsNotifier() : super([]);

  clearQuestions() {
    state = [];
  }

  Future<void> addQuestions(List<Question> questionsToAdd) async {
    // print('questionsToAdd from AddQuestionsNotifier: $questionsToAdd');
    // Create a new list to store the unique questions.
    List<Question> uniqueQuestionsToAdd = questionsToAdd.toSet().toList();

    /// toSet() removes duplicates
    List<Question> uniqueQuestions = [];

    // Iterate through each question to be added.
    for (Question question in uniqueQuestionsToAdd) {
      // Check if the question already exists in the state.
      if (!state.contains(question)) {
        // If the question does not exist, add it to the new list.
        uniqueQuestions.add(question);
      }
    }

    // Update the state with the unique questions.
    state = [...state, ...uniqueQuestions];
  }

  get questions => state;
}

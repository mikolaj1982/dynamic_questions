import 'package:conditional_questions_simplified/question.dart';
import 'package:conditional_questions_simplified/question_data_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class  QuestionData {
  final dynamic condition;
  final List<Question> questions;

  QuestionData({
    required this.condition,
    required this.questions,
  });

  @override
  String toString() {
    return 'QuestionData(condition: $condition, questions: $questions) \n\n';
  }
}

final questionDataProvider = Provider.family<List<QuestionData>, String>((ref, questionName) {
  final questionData = ref.watch(questionDataListProvider).data;
  return questionData.where((QuestionData data) => data.condition.toString().contains(questionName)).toList();
}, name: 'questionDataProvider');

final questionDataListProvider = StateNotifierProvider<QuestionDataListNotifier, QuestionDataList>(
  (ref) => QuestionDataListNotifier(),
  name: 'questionDataList',
);

final nestedQuestionsProvider = StateNotifierProvider<AddQuestionsNotifier, List<Question>>(
  (ref) => AddQuestionsNotifier(),
  name: 'nestedQuestionsProvider',
);

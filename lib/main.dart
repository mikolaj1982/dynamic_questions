import 'dart:convert';
import 'dart:math';

import 'package:conditional_questions_simplified/model/question.dart';
import 'package:conditional_questions_simplified/providers/question_data.dart';
import 'package:conditional_questions_simplified/question_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'checkbox.dart';
import 'constants/schema_json_string.dart';
import 'package:json_schema3/json_schema3.dart';
import 'main.dart';

final container = ProviderContainer();

void main() {
  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      debugShowMaterialGrid: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      debugPrint('analyzing data');
      final schema = jsonDecode(schemaRawString) as Map<String, dynamic>;
      final List<QuestionData> questionData = _buildQuestions(schema);
      ref.read(questionDataListProvider.notifier).updateData(questionData);
    });
  }

  Question _getQuestion(String name) {
    final schema = jsonDecode(schemaRawString) as Map<String, dynamic>;
    final questionProps = schema['properties'][name];
    final q = Question(
      name: name,
      sectionHint: questionProps['sectionHint'],
      type: questionProps['type'],
      title: questionProps['title'],
      questionType: questionProps['questionType'],
    );

    // debugPrint('question: $q');
    return q;
  }

  bool checkIfCheckbox(Question question) {
    switch (question.questionType) {
      case 'yesNo':
        return true;
      default:
        return false;
    }
  }

  List<QuestionData> _buildQuestions(Map<String, dynamic> schema) {
    final List<QuestionData> questionData = [];
    final Map<dynamic, dynamic> questionsMap = {};

    final allOf = schema['allOf'] as List<dynamic>?;
    if (allOf == null) {
      return [];
    }

    for (final item in allOf) {
      final condition = item['if'] as Map<String, dynamic>?;
      final then = item['then'] as Map<String, dynamic>?;
      if (condition != null && then != null) {
        final String property = condition[r'$ref']?.split('/')?.last;
        final jsonSchema = JsonSchema.create(schemaRawString);
        Map<String, dynamic>? conditionToMeet;
        for (var key in jsonSchema.schemaMap!.keys) {
          if (key == 'definitions') {
            conditionToMeet = jsonSchema.schemaMap![key][property];
          }
        }

        final Map<String, dynamic>? reqProperties =
            _getRequiredDefinition(jsonSchema, 'askWhen${capitalize(property)}');
        if (reqProperties != null) {
          List<Question> conditionalQuestions = [
            ...reqProperties['required'].map((property) => _getQuestionBasedOnPropertyFromSchema(jsonSchema, property))
          ];
          questionsMap.putIfAbsent(property, () => conditionalQuestions);
          questionData.add(QuestionData(
            condition: conditionToMeet,
            questions: questionsMap[property],
          ));
          print(conditionToMeet);
          print(questionsMap[property]);
          print('-------------------------------------');
        }
      }
    }

    return questionData;
  }

  Question? _getQuestionBasedOnPropertyFromSchema(JsonSchema schema, String property) {
    final JsonSchema? json = schema.properties[property];

    if (json != null) {
      return Question(
        name: property,
        title: json.title ?? "",
        type: json.schemaMap!['type'] ?? "",
        questionType: json.schemaMap!['questionType'] ?? "",
        sectionHint: json.schemaMap!['sectionHint'] ?? "",
        response: null,
        possibleValues: null,
      );
    }
    return null;
  }

  Map<String, dynamic>? _getRequiredDefinition(JsonSchema schema, final dynamic data) {
    Map<String, dynamic>? reqProps;
    for (var key in schema.schemaMap!.keys) {
      if (key == 'definitions') {
        reqProps = schema.schemaMap![key][data];
      }
    }

    return reqProps;
  }

  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input[0].toUpperCase() + input.substring(1);
  }

  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._buildQuestionWidgets(ref),
            ],
          ),
        ),
      ),
    );
  }

  _buildQuestionWidgets(ref) {
    final questions = [];

    // final questions = [
    //   Question(
    //     name: 'question1',
    //     type: 'checkbox',
    //     title: 'Question 1',
    //     sectionHint: 'Section 1',
    //     questionType: 'yesNo',
    //   ),
    //   Question(
    //     name: 'question2',
    //     type: 'checkbox',
    //     title: 'Question 2',
    //     sectionHint: 'Section 1',
    //     questionType: 'yesNo',
    //   ),
    //   Question(
    //     name: 'question3',
    //     type: 'checkbox',
    //     title: 'Question 3',
    //     sectionHint: 'Section 1',
    //     questionType: 'yesNo',
    //   ),
    //   Question(
    //     name: 'question4',
    //     type: 'checkbox',
    //     title: 'Question 4',
    //     sectionHint: 'Section 1',
    //     questionType: 'yesNo',
    //   ),
    //   Question(
    //     name: 'question5',
    //     type: 'checkbox',
    //     title: 'Question 5',
    //     sectionHint: 'Section 1',
    //     questionType: 'yesNo',
    //   ),
    // ];

    final schema = jsonDecode(schemaRawString) as Map<String, dynamic>;
    for (String question in schema['required']) {
      final q = _getQuestion(question);
      questions.add(q);
    }

    var listOfWidgets = [];
    for (final question in questions) {
      /// add conditional logic to check the type of the question
      if (checkIfCheckbox(question)) {
        listOfWidgets.add(QuestionWidget(
          key: ValueKey(question.name + generateRandomNumber(1000, 99990).toString()),
          question: question,
          widgetToRender: TristateCheckbox(
            // key: ValueKey(question.name),
            onStateChanged: () => () {
              print('onStateChanged');
            },
            question: question,
          ),
        ));
      } else {
        listOfWidgets.add(QuestionWidget(
          key: ValueKey(question.name + generateRandomNumber(1000, 99990).toString()),
          widgetToRender: Flexible(
            child: TextFormField(
              // key: ValueKey(question.name),
              decoration: InputDecoration(
                labelText: question.title,
              ),
              onChanged: (value) {
                print('text field value changed to $value');
              },
            ),
          ),
          question: question,
        ));
      }
    }

    return listOfWidgets;
  }
}

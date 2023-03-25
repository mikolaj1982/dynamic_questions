import 'dart:convert';
import 'package:conditional_questions_simplified/question.dart';
import 'package:conditional_questions_simplified/question_data.dart';
import 'package:conditional_questions_simplified/question_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_schema3/json_schema3.dart';
import 'package:flutter/material.dart';
import 'checkbox_form_field.dart';
import 'constants.dart';

class CustomProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {
//     print('''
// Provider: ${provider.name ?? provider.runtimeType},
// Old Value: $newValue
// New Value: $previousValue,
// =======================
// ''');
    super.didUpdateProvider(provider, previousValue, newValue, container);
  }
}

final container = ProviderContainer(observers: [CustomProviderObserver()]);

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
    Future.delayed(Duration.zero, () {
      debugPrint('analyzing data');
      final schema = jsonDecode(schemaRawString) as Map<String, dynamic>;
      final List<QuestionData> questionData = _buildQuestions(schema);
      ref.read(questionDataListProvider.notifier).updateData(questionData);
    });
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
    final schema = jsonDecode(schemaRawString) as Map<String, dynamic>;
    for (String question in schema['required']) {
      final q = _getQuestion(question);
      questions.add(q);
    }

    var listOfWidgets = [];
    for (final question in questions) {
      /// add conditional logic to check the type of the question
      if (_checkIfCheckbox(question)) {
        listOfWidgets.add(QuestionWidget(
          key: ValueKey(question.name),
          question: question,
          widgetToRender: TristateCheckbox(
            // key: ValueKey(question.name),
            question: question,
            onStateChanged: (bool) {},
          ),
        ));
      } else {
        listOfWidgets.add(QuestionWidget(
          key: ValueKey(question.name),
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

    // int startIndex = 10; // Start from index 10 (0-based)
    // int itemCount = 1; // Take 5 items
    // return listOfWidgets.skip(startIndex).take(itemCount);
    return listOfWidgets;
  }

  bool _checkIfCheckbox(Question question) {
    switch (question.questionType) {
      case 'yesNo':
        return true;
      default:
        return false;
    }
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

  List<QuestionData> _buildQuestions(Map<String, dynamic> schema) {
    final List<QuestionData> questionData = [];
    final Map<dynamic, dynamic> questionsMap = {};
    final allOf = schema['allOf'] as List<dynamic>?;
    if (allOf == null) {
      return [];
    }

    final jsonSchema = JsonSchema.create(schemaRawString);
    final definitions = jsonSchema.schemaMap!['definitions'] as Map<String, dynamic>?;
    for (final item in allOf) {
      final condition = item['if'] as Map<String, dynamic>?;
      final then = item['then'] as Map<String, dynamic>?;
      if (condition != null && then != null) {
        final String property = condition[r'$ref']?.split('/')?.last;
        Map<String, dynamic>? conditionToMeet = definitions?[property];
        final Map<String, dynamic>? reqProperties =
            _getRequiredDefinition(jsonSchema, 'askWhen${capitalize(property)}');
        if (reqProperties != null) {
          List<Question> conditionalQuestions = _getConditionalQuestions(reqProperties, jsonSchema);
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

  List<Question> _getConditionalQuestions(Map<String, dynamic> reqProperties, JsonSchema jsonSchema) {
    List<Question> conditionalQuestions = [];
    for (String property in reqProperties['required']) {
      Question? question = _getQuestionBasedOnPropertyFromSchema(jsonSchema, property);
      if (question != null) {
        conditionalQuestions.add(question);
      }
    }
    return conditionalQuestions;
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
}

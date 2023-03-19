import 'package:conditional_questions_simplified/question.dart';
import 'package:conditional_questions_simplified/question_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'checkbox.dart';

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
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    final questions = [
      Question(
        name: 'question1',
        type: 'checkbox',
        title: 'Question 1',
        sectionHint: 'Section 1',
        questionType: 'yesNo',
      ),
      Question(
        name: 'question2',
        type: 'checkbox',
        title: 'Question 2',
        sectionHint: 'Section 1',
        questionType: 'yesNo',
      ),
      Question(
        name: 'question3',
        type: 'checkbox',
        title: 'Question 3',
        sectionHint: 'Section 1',
        questionType: 'yesNo',
      ),
      Question(
        name: 'question4',
        type: 'checkbox',
        title: 'Question 4',
        sectionHint: 'Section 1',
        questionType: 'yesNo',
      ),
      Question(
        name: 'question5',
        type: 'checkbox',
        title: 'Question 5',
        sectionHint: 'Section 1',
        questionType: 'yesNo',
      ),
    ];

    var listOfWidgets = [];
    for (final question in questions) {
      listOfWidgets.add(QuestionWidget(
        key: ValueKey(question.name),
        question: question,
        widgetToRender: TristateCheckbox(
          question: question,
          onStateChanged: () =>  (){
            print('onStateChanged');
          },
        ),
      ));
    }

    return listOfWidgets;
  }
}

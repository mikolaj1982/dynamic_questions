import 'package:conditional_questions_simplified/model/question.dart';
import 'package:conditional_questions_simplified/providers/question_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'checkbox.dart';
import 'main.dart';

class QuestionWidget extends ConsumerStatefulWidget {
  QuestionWidget({
    Key? key,
    required this.question,
    required this.widgetToRender,
  }) : super(key: key);

  final Question question;
  List<Question>? nestedQuestions = [];
  final Widget widgetToRender;

  @override
  ConsumerState<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends ConsumerState<QuestionWidget> {
  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min);
  }

  // void _addNestedQuestions(String parentWidgetName) {
  //   print('addNestedQuestions: $parentWidgetName');
  //   int randomNumber = generateRandomNumber(1000, 9999);
  //   final newQuestion = Question(
  //     name: 'question$randomNumber',
  //     type: 'checkbox',
  //     title: 'Question 6',
  //     sectionHint: 'Section 1',
  //     questionType: 'yesNo',
  //   );
  //   setState(() {
  //     widget.nestedQuestions!.add(newQuestion);
  //   });
  // }

  void _clearNestedQuestions() {
    ref.read(nestedQuestionsProvider.notifier).clearQuestions();
    setState(() {
      widget.nestedQuestions?.clear();
      widget.nestedQuestions = null;
      widget.nestedQuestions = [];
    });
  }

  void _addNestedQuestions(String parentWidgetName) {
    final List<QuestionData> questionDataList = ref.watch(questionDataProvider(parentWidgetName));
    setState(() {
      _clearNestedQuestions();

      for (QuestionData questionData in questionDataList) {
        Map<String, dynamic> conditionMap = questionData.condition['properties'];
        bool allConditionsMet = true;
        List<Question> questionsToAdd = [];
        for (var entry in conditionMap.entries) {
          // var value = entry.value;
          var key = entry.key;
          // print('$key: $value');
          // print('Number of conditions: ${conditionMap.entries.length}');

          final AutoDisposeStateProvider<bool>? provider = _getProviderByName(key);
          // final StateProvider<bool>? provider = _getProviderByName(key);

          if (provider == null) {
            allConditionsMet = false;
          } else {
            var boolToMatch = conditionMap[key]["const"];
            final actualValue = ref.read(provider.notifier).state;
            if (boolToMatch == actualValue) {
              // print('condition matched on property $key with value $actualValue');
              List<Question> questions = questionData.questions;
              for (int i = 0; i < questions.length; i++) {
                Question question = questions[i];
                questionsToAdd.add(question);
              }
              // break;
            } else {
              allConditionsMet = false;
              // print('condition NOT matched on property $key with value $actualValue');
            }
          }
        }

        if (allConditionsMet) {
          // print('All conditions are true.');
          _clearNestedQuestions();
          ref.read(nestedQuestionsProvider.notifier).addQuestions(questionsToAdd);
          final questions = ref.read(nestedQuestionsProvider.notifier).questions;
          widget.nestedQuestions?.addAll(questions);
        }

        // print('=================================================================');
      }
    });

    print('=================================================================');
  }

  dynamic _getProviderByName(String name) {
    // print('looking for provider with name: $name');
    final providerElements = container.getAllProviderElements();
    for (final ProviderElementBase<Object?> element in providerElements) {
      if (element.provider.name == name) {
        // print('found provider with name: $name');
        return element.provider;
      }
    }

    return null;
  }

  bool checkIfCheckbox(Question question) {
    switch (question.questionType) {
      case 'yesNo':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // var checkboxState = _getProviderByName(widget.question.name);
    // if (checkboxState != null) {
    //   bool state = ref.watch(checkboxState);
    //   if (state) {
    //     print('QuestionWidgetState: ${checkboxState.name} checkbox is $state.');
    //     _addNestedQuestions(widget.question.name);
    //   }
    // }

    var checkboxState = _getProviderByName(widget.question.name);
    if (checkboxState != null) {
      ref.listen(checkboxState, (_, state) {
        print('_QuestionWidgetState: ${checkboxState.name} checkbox is $state.');
        _addNestedQuestions(widget.question.name);
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                widget.widgetToRender,
                (widget.widgetToRender.runtimeType == TristateCheckbox &&
                    (widget.question.name == 'livingInNZ' ||
                        widget.question.name == 'intendStayingInNZ' ||
                        widget.question.name == 'holdsNZPassportVisa' ||
                        widget.question.name == 'usingForeignPassport' ||
                        widget.question.name == 'holdsAustralianPassport' ||
                        widget.question.name == 'hasPrisonOrDeportationHistory' ||
                        widget.question.name == 'bringingAnyFood' ||
                        widget.question.name == 'bringingOutdoorActivityItems'))
                    ? TextButton(
                  onPressed: () {
                    _addNestedQuestions(widget.question.name); // call the callback function
                  },
                  child: Text('add'),
                )
                    : Container(),
              ],
            ),
            // Container(
            //   color: Colors.red,
            //   child: Text('nestedQuestions: ${widget.nestedQuestions?.length}'),
            // ),
            Column(
              children: [
                if (widget.nestedQuestions != null)
                  ...widget.nestedQuestions!.map((Question question) {
                    //FIXME add same code for global keys to be able to grab the right widget for nested questions
                    if (checkIfCheckbox(question)) {
                      return QuestionWidget(
                        key: ValueKey(question.name + generateRandomNumber(1000, 99999).toString()),
                        question: question,
                        widgetToRender: TristateCheckbox(
                          onStateChanged: () =>  _addNestedQuestions(widget.question.name),
                          question: question,
                        ),
                      );
                    } else {
                      return QuestionWidget(
                        key: ValueKey(question.name + generateRandomNumber(1000, 99999).toString()),
                        widgetToRender: Flexible(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: question.title,
                            ),
                            onChanged: (value) {
                              print('text field value changed to $value');
                            },
                          ),
                        ),
                        question: question,
                      );
                    }
                  }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:conditional_questions_simplified/question.dart';
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
  final List<Question>? nestedQuestions = [];
  final Widget widgetToRender;

  @override
  ConsumerState<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends ConsumerState<QuestionWidget> {
  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min);
  }

  void _addNestedQuestions(String parentWidgetName) {
    print('addNestedQuestions: $parentWidgetName');
    int randomNumber = generateRandomNumber(1000, 9999);
    final newQuestion = Question(
      name: 'question$randomNumber',
      type: 'checkbox',
      title: 'Question 6',
      sectionHint: 'Section 1',
      questionType: 'yesNo',
    );
    setState(() {
      widget.nestedQuestions!.add(newQuestion);
    });
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

  @override
  Widget build(BuildContext context) {
    var checkboxState = _getProviderByName(widget.question.name);
    if (checkboxState != null) {
      bool state = ref.watch(checkboxState);
      if (state) {
        print('QuestionWidgetState: ${checkboxState.name} checkbox is $state.');
        _addNestedQuestions(widget.question.name);
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.widgetToRender,
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _addNestedQuestions(widget.question.name);
                    },
                    child: Text('add'),
                  )
                ],
              ),
              Column(
                children: [
                  if (widget.nestedQuestions != null)
                    ...widget.nestedQuestions!.map((Question question) {
                      return QuestionWidget(
                        key: ValueKey(question.name),
                        question: question,
                        widgetToRender: TristateCheckbox(
                          question: question,
                          onStateChanged: () =>  _addNestedQuestions(widget.question.name),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

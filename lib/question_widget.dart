import 'package:conditional_questions_simplified/question.dart';
import 'package:conditional_questions_simplified/question_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'checkbox_form_field.dart';

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
  static Map<String, _QuestionWidgetState> instanceMap = {};
  DateTime _lastMethodCallTime = DateTime.fromMillisecondsSinceEpoch(0);

  dynamic _getProviderByName(BuildContext context, String name) {
    final container = ProviderScope.containerOf(context);
    final providerElements = container.getAllProviderElements();
    for (final ProviderElementBase<Object?> element in providerElements) {
      if (element.provider.name == name) {
        return element.provider;
      }
    }

    return null;
  }

  bool _checkIfCheckbox(Question question) {
    switch (question.questionType) {
      case 'yesNo':
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    ///FIXME for first time, the state is not set yet, so we need to wait for the next frame
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
    super.initState();
  }

  void _clearNestedQuestions() {
    ref.read(nestedQuestionsProvider.notifier).clearQuestions();
    widget.nestedQuestions?.clear();
  }

  bool _canCallMethod() {
    final now = DateTime.now();
    if (now.difference(_lastMethodCallTime) >= const Duration(milliseconds: 100)) {
      _lastMethodCallTime = now;
      return true;
    }
    return false;
  }

  void _addNestedQuestionsFromRootWidget(String parentWidgetName) {
    if (!mounted) {
      return;
    }

    if (_canCallMethod()) {
      final List<QuestionData> questionDataList = ref.watch(questionDataProvider(parentWidgetName));
      if (questionDataList.isNotEmpty) {
        setState(() {
          _clearNestedQuestions();
          for (QuestionData questionData in questionDataList) {
            List<Question> questionsToAdd = _processQuestionData(questionData);
            if (questionsToAdd.isNotEmpty) {
              _clearNestedQuestions();
              ref.read(nestedQuestionsProvider.notifier).addQuestions(questionsToAdd);
              final questions = ref.read(nestedQuestionsProvider.notifier).questions;
              widget.nestedQuestions?.addAll(questions);
            }
          }
        });
      }
    }
  }

  List<Question> _processQuestionData(QuestionData questionData) {
    Map<String, dynamic> conditionMap = questionData.condition['properties'];
    bool allConditionsMet = true;
    List<Question> questionsToAdd = [];

    for (var entry in conditionMap.entries) {
      var key = entry.key;
      final AutoDisposeStateProvider<bool>? provider = _getProviderByName(context, key);
      if (provider == null) {
        allConditionsMet = false;
      } else {
        var boolToMatch = conditionMap[key]["const"];
        final actualValue = ref.read(provider.notifier).state;
        if (boolToMatch == actualValue) {
          questionsToAdd.addAll(questionData.questions);
        } else {
          allConditionsMet = false;
        }
      }
    }

    return allConditionsMet ? questionsToAdd : [];
  }

  void _assignThis(String parentWidgetName, _QuestionWidgetState? questionWidgetState) {
    instanceMap[parentWidgetName] = questionWidgetState!;
  }

  void _scheduleAssignThis() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assignThis(widget.question.name, this);
    });
  }

  @override
  Widget build(BuildContext context) {
    var checkboxState = _getProviderByName(context, widget.question.name);
    if (checkboxState != null) {
      ref.listen(checkboxState, (_, state) {
        _addNestedQuestionsFromRootWidget(widget.question.name);
      });
    }

    _scheduleAssignThis();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
      child: Column(
        children: [
          Row(
            children: [
              widget.widgetToRender,
            ],
          ),
          Column(
            children: [
              if (widget.nestedQuestions != null)
                ...widget.nestedQuestions!.map((Question question) {
                  if (_checkIfCheckbox(question)) {
                    return QuestionWidget(
                      question: question,
                      widgetToRender: TristateCheckbox(
                        onStateChanged: (bool newValue) {
                          ref.read(_getProviderByName(context, question.name).notifier).state = newValue;
                          instanceMap[question.name]?._addNestedQuestionsFromRootWidget(question.name);
                        },
                        question: question,
                      ),
                    );
                  } else {
                    return QuestionWidget(
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
    );
  }
}

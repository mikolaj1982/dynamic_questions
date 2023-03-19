import 'package:conditional_questions_simplified/question.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ExtendedFormField extends FormField<bool?> {
  ExtendedFormField(
      {super.key,
      Widget? title,
      FormFieldSetter<bool?>? onChanged,
      FormFieldValidator<bool?>? validator,
      bool? initialValue})
      : super(
          onSaved: onChanged,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<bool?> state) {
            return Flexible(
              child: CheckboxListTile(
                tristate: false,
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: (v) {
                  state.didChange(v);
                  state.save();
                  // widget.onStateChanged();
                },
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        );
}

class TristateCheckbox extends ConsumerStatefulWidget {
  final Question question;
  final VoidCallback onStateChanged;

  const TristateCheckbox({
    super.key,
    required this.question,
    required this.onStateChanged,
  });

  @override
  ConsumerState<TristateCheckbox> createState() => _TristateCheckboxState();
}

class _TristateCheckboxState extends ConsumerState<TristateCheckbox> {
  dynamic _checkboxState;

  @override
  void initState() {
    super.initState();
    _checkboxState = StateProvider.autoDispose(
      (ref) => false,
      name: widget.question.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedFormField(
      initialValue: ref.watch(_checkboxState.notifier).state,
      title: Text(widget.question.title),
      onChanged: (value) {
        // print('value: $value');
        setState(() {
          ref.read(_checkboxState.notifier).state = value;
        });
        widget.onStateChanged!();
      },
    );
  }
}

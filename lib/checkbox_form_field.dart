import 'package:conditional_questions_simplified/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Function(bool) onStateChanged;

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
  bool? _value = false;

  @override
  void initState() {
    super.initState();
    _checkboxState = StateProvider.autoDispose(
      (ref) => false,
      name: widget.question.name,
    );
  }

  void _onChanged(bool? value) {
    setState(() {
      _value = value;
    });
    widget.onStateChanged(value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedFormField(
      initialValue: ref.watch(_checkboxState.notifier).state,
      title: Text(widget.question.title),
      onChanged: (value) {
        _onChanged(value);
        setState(() {
          ref.read(_checkboxState.notifier).state = value;
        });
      },
    );
  }
}

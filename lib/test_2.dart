import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Parent-Child Example')),
        body: ParentWidget(),
      ),
    );
  }
}

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  void onChildAction() {
    print('Action received from child widget');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChildWidget(onAction: onChildAction),
    );
  }
}

class ChildWidget extends StatelessWidget {
  final VoidCallback onAction;

  ChildWidget({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onAction,
      child: Text('Trigger action in parent'),
    );
  }
}

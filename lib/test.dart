import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<_ParentWidgetState> parentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Global Key Example')),
        body: ParentWidget(key: parentKey),
      ),
    );
  }
}

class ParentWidget extends StatefulWidget {
  ParentWidget({required Key key}) : super(key: key);

  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  void onChildAction() {
    print('Action received from child widget');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action received from child widget')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChildWidget(parentKey: widget.key as GlobalKey<_ParentWidgetState>),
    );
  }
}

class ChildWidget extends StatelessWidget {
  final GlobalKey<_ParentWidgetState> parentKey;

  ChildWidget({required this.parentKey});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => parentKey.currentState?.onChildAction(),
      child: Text('Trigger action in parent'),
    );
  }
}

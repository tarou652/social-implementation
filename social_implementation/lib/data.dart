import 'package:SI/components/footer.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';

void main() {
  runApp(DataPage());
}

class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "解析"),
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      body: Container(
      ),
      bottomNavigationBar:Footer(currentIndex: 2,context: context,selected: 0),
    );

  }
}
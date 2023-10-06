import 'package:SI/components/fotter.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';

void main() {
  runApp(HistoryPage());
}

class HistoryPage extends StatelessWidget {
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
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "履歴"),
      body: Container(
        height: 400,
        width: double.infinity,
        color: Colors.blue,
        child:Padding(
          padding: EdgeInsets.all(20 ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,//画面の真ん中に
          children: <Widget>[
            Text(
              'You have pushed the buts:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        )
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), 
       bottomNavigationBar:Footer(currentIndex: 2,context: context),
      
    );

  }
}
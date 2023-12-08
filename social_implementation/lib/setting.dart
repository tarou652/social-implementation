import 'package:SI/components/fotter.dart';
import 'package:SI/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    SettingPage(),);
}

class SettingPage extends StatelessWidget {
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
  final _formKey = GlobalKey<FormState>();
  DateTime dateTime = DateTime.now();
  bool _value = true;
  int _counter = 0;
  List<DateTime> history = [];
  List<bool> historySwitchValues = List.generate(100, (index) => true);

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void saveDateTime(){
    setState((){
      history.add(dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(text: "設定"),
      backgroundColor: Color(0xffFEF6E4),
      body: SingleChildScrollView(
        child: _form(),
      ),
      bottomNavigationBar:Footer(currentIndex: 1,context: context),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '時間指定',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    saveDateTime();
                  },
                  style: TextButton.styleFrom(
                    primary: Color(0xffF582AE),
                  ),
                  child: Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: dateTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: true,
                onDateTimeChanged: (DateTime newTime) {
                  setState(() => dateTime = newTime);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自動録音',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoSwitch(
                  activeColor: Color(0xff8BD3DD),
                  trackColor: Color(0xff545C81),
                  value: _value,
                  onChanged: (value) => setState(() => _value = value),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '指定履歴',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff001858),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1, // 区切り線の太さを指定
              color: Color(0xffB2B3BA), // 区切り線の色を指定
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history.asMap().entries.map((entry) {
                  final index = entry.key;
                  final savedDateTime = entry.value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${savedDateTime.year}/${savedDateTime.month}/${savedDateTime.day}',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold, // 太文字にする
                                  ),
                                ),
                                Text(
                                  '${savedDateTime.hour}:${savedDateTime.minute}',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xff001858),
                                    fontWeight: FontWeight.bold, // 太文字にする
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              activeColor: Color(0xff8BD3DD),
                              trackColor: Color(0xff545C81),
                              value: historySwitchValues[index],
                              onChanged: (value) {
                                setState(() {
                                  historySwitchValues[index] = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 1, // 区切り線の太さを指定
                          color: Color(0xffB2B3BA), // 区切り線の色を指定
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
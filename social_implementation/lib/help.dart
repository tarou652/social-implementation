import 'package:SI/components/footer.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(HelpPage());
}

class HelpPage extends StatelessWidget {
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
      appBar: Header(text: "ヘルプ"),
      backgroundColor: Color(0xffFEF6E4),

      body: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          ExpansionTile(
            title: Text(
                '録音履歴について',
                style: TextStyle(color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '録音されたデータは日付ごとに昇順でリストされます。\n'
                        'データには、日時のほかに録音開始時刻と平均㏈値が表示されます。\n',
                        style: TextStyle(color: Color(0xff001858)),
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Image.network(
                      'https://i-storage.tenki.jp/large/storage/static-images/suppl/article/image/2/27/277/27715/2/large.jpg',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
                '時間設定について',
                style: TextStyle(color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '時間設定では、ユーザーが時間を設定することでその時間に自動録音を開始することができます。\n'
                        'また以前の録音時間が保存されるので、履歴からオンオフで同じ時間の録音が可能になります。\n'
                        '自動録音機能をご使用になる場合は、自動録音の許可をしてください。\n',
                        style: TextStyle(color: Color(0xff001858)),
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Image.network(
                      'https://i-storage.tenki.jp/large/storage/static-images/suppl/article/image/2/27/277/27715/2/large.jpg',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
                '録音画面について',
                style: TextStyle(color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '録音画面では、音声の録音を行います。\n'
                        'ユーザーが開始ボタンを押すと録音が開始され上部に経過秒数と音のノイズが表示されます。\n'
                        '録音機能を使用するにはマイクの許可をしてください。\n',
                        style: TextStyle(color: Color(0xff001858)),
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Image.network(
                      'https://i-storage.tenki.jp/large/storage/static-images/suppl/article/image/2/27/277/27715/2/large.jpg',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
                'アンケート',
                style: TextStyle(color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap: () {
                    _launchURL('https://forms.office.com/pages/responsepage.aspx?id=XYP-cpVeEkWK4KezivJfyMCO0vGn8KlHnna6XBkyMlBUMjBNMlJEWjlVQTZLTUhIVDdVOUJKMFdSSS4u'); //URL
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'アンケートへのご協力お願いします\n',
                          style: TextStyle(color: Color(0xff001858)),
                        ),
                        TextSpan(
                          text: '回答はこちら',
                          style: TextStyle(color: Color(0xffF582AE)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar:Footer(currentIndex: 2,context: context),
    );
  }

  _launchURL(String url) async {
    try {
      final encodedUrl = Uri.encodeFull(url);

      await launch(
        encodedUrl,
        forceSafariVC: false,
        universalLinksOnly: true,
      );
    } catch (e) {
      throw 'Could not launch $url';
    }
  }
}
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
                style: TextStyle(fontSize: 20.0, color: Color(0xff001858)),
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
                      'https://media.discordapp.net/attachments/1112618371914141702/1197721912231596032/image.png?ex=65bc4c74&is=65a9d774&hm=55799c006f8bba381457df7b3e1bdc39e3a3ff9ca0a25225513ab1b043b0ea5f&=&format=webp&quality=lossless&width=331&height=662',
                      width: 100.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
                '履歴画面について',
                style: TextStyle(fontSize: 20.0, color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '録音されたファイルは、新着順に一覧で表示されます。\n'
                        '再生ボタンを押すことで、選択した録音ファイルの再生が開始されます。\n'
                        '削除ボタンを押すことで、選択された録音ファイルが削除されます。\n'
                        '録音された騒音の最大dB値が表示されます。\n',
                        style: TextStyle(color: Color(0xff001858)),
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Image.network(
                      'https://media.discordapp.net/attachments/1112618371914141702/1197722871452139552/image.png?ex=65bc4d59&is=65a9d859&hm=c167d9b5150dfaf036e7991114f65fe2928fd44b86c443bc7eba61ba5c4797a5&=&format=webp&quality=lossless&width=333&height=662',
                      width: 100.0,
                      height: 200.0,
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
                style: TextStyle(fontSize: 20.0, color: Color(0xff001858)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '録音画面では、音声の録音を行います。\n'
                        'ユーザーが開始ボタンを押すと録音が開始され上部に経過秒数が表示されます。\n'
                        '\n'
                        '緑の開始ボタンは通常録音のボタンであり、開始ボタンが押されて停止ボタンが押されるまでの音声を録音します。\n'
                            '\n'
                        '赤の開始ボタンは自動録音のボタンであり、ユーザーが開始ボタンを押すと10秒の録音を開始します。10秒間で規定のdB値を超えなければそのデータは破棄され、超えたら保存されます。これを停止ボタンが押されるまで続きます。\n'
                        ,
                        style: TextStyle( color: Color(0xff001858)),
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Image.network(
                      'https://cdn.discordapp.com/attachments/1112618371914141702/1197723491315748955/image.png?ex=65bc4dec&is=65a9d8ec&hm=6ab3b9fab531897fe04f7a845235bee87171e9d6fedf4dc3108729bb5e2ee3f2&',
                      width: 100.0,
                      height: 200.0,
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
                    _launchURL('https://forms.office.com/r/yrtF0YnDb3'); //URL
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
      bottomNavigationBar:Footer(currentIndex: 3,context: context,isStart: false,),
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
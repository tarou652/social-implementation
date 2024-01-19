import 'dart:io';

import 'package:SI/components/footer.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

////////////////////////////////////////////////////////////////

void main() {
  runApp(DataPage());
}


class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(text: "騒音対策"),
        backgroundColor: Color(0xffFEF6E4),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: AppBody(),
              ),
            ),
            Footer(currentIndex: 2,context: context,),
          ],
        ),
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {


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

    );

  }
}
class AppBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(254, 246, 228, 1),

      padding: EdgeInsets.all(16.0),

      child: Column(
        children: [

          // NoiseCard(
          //   title: '昨夜の睡眠dB値',
          //   subTitle1: '最大dB値(dB)',
          //   subTitle2: '検知回数(回)',
          //   subTitle3: '',
          // ),
          SizedBox(height: 16.0),
          SevenDaysChart(title: '過去7日間'),
          SizedBox(height: 16.0),




        ],
      ),
    );
  }
}

class NoiseCard extends StatelessWidget {

  final String subTitle1;
  final String subTitle2;
  final String subTitle3;
  final int Maxdb;
  final int Sumfile;
  const NoiseCard({

    required this.subTitle1,
    required this.subTitle2,
    required this.subTitle3,
    required this.Maxdb,
    required this.Sumfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0,
      child: Container(
        height: 200.0,
        width: double.infinity,

        decoration: BoxDecoration(

          color: Color.fromRGBO(254, 246, 228, 1),


        ),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      height: 200.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),

                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // 影の色と透明度
                            spreadRadius: 1.0, // 影の広がり
                            blurRadius: 1.0, // 影のぼかし
                            offset: Offset(0, 0), // 影の位置 (x, y)
                          ),
                        ],

                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                             child: Text(
                                subTitle1,
                               style: TextStyle(fontSize: 25.0, color: Color.fromRGBO(0, 24, 88, 1)),

                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: 150.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),

                                  color: Colors.white,


                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "$Maxdb",
                                        style: TextStyle(fontSize: 80.0, color: Color.fromRGBO(
                                            255, 123, 123, 1.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 200.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // 影の色と透明度
                            spreadRadius: 1.0, // 影の広がり
                            blurRadius: 1.0, // 影のぼかし
                            offset: Offset(0, 0), // 影の位置 (x, y)
                          ),
                        ],

                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subTitle2,
                              style: TextStyle(fontSize: 25.0, color: Color.fromRGBO(0, 24, 88, 1)),

                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: 150.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "$Sumfile",
                                        style: TextStyle(fontSize: 80.0, color: Color.fromRGBO(
                                            110, 110, 124, 1.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
    );
  }
}



class SevenDaysChart extends StatefulWidget {
  final String title;

  SevenDaysChart({required this.title});

  @override
  _SevenDaysChartState createState() => _SevenDaysChartState();
}


//以下がグラフのコード
class _SevenDaysChartState extends State<SevenDaysChart> {
  final  Directory directory = Directory('');
  List<String> AutodbList =[];
  List<String> Autofiles =[];
  List<int> Aweeknum=[0,0,0,0,0,0,0];
  int Maxdb = 0;
  int SumFile =0;
  @override
  void initState() {
    super.initState();
    LoadAutoFile();
  }
  Future<void> LoadAutoFile() async {
    print("ASdwasdwasdwasdw");
    final directory = await getApplicationDocumentsDirectory();
    final  AutodbFolderPath = '${directory.path}/Autodb';
    final AutodbDirectory = Directory(AutodbFolderPath);
    final AutodbPaths = AutodbDirectory.listSync();
    List<String> itizilist =[];

    for (var file in AutodbPaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
    }
    AutodbList = itizilist;
    itizilist=[];
    final AutorecordingFolderPath = '${directory.path}/Auto';
    final AutorecordingDirectory = Directory(AutorecordingFolderPath);
    final Autofilespaths = AutorecordingDirectory.listSync();
    for (var file in Autofilespaths) {
      String fileName = basename(file.path);
      itizilist.add(fileName);
      List<String> parts = fileName.split(",");
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);
      DateTime fileday = DateTime(year, month, day);
      DateTime now = DateTime.now();
      DateTime Today = DateTime(now.year, now.month, now.day);
      Duration difference = Today.difference(fileday);
      switch (difference.inDays) {
        case 0:
          Aweeknum[0]=Aweeknum[0]+1;
          SumFile=SumFile+1;
          int targetnum= Autofilespaths.indexOf(file);
          List<String> parts = AutodbList[targetnum].split(',');
          int targetdb=int.parse(parts[1]);
          if(targetdb > Maxdb){
            Maxdb =targetdb;
          }
          break;
        case 1:
          Aweeknum[1]=Aweeknum[1]+1;
          SumFile=SumFile+1;
          int targetnum= Autofilespaths.indexOf(file);
          List<String> parts = AutodbList[targetnum].split(',');
          int targetdb=int.parse(parts[1]);
          if(targetdb > Maxdb){
            Maxdb =targetdb;
          }
          break;
        case 2:
          Aweeknum[2]=Aweeknum[2]+1;
          break;
        case 3:
          Aweeknum[3]=Aweeknum[3]+1;
          break;
        case 4:
          Aweeknum[4]=Aweeknum[4]+1;
          break;
        case 5:
          Aweeknum[5]=Aweeknum[5]+1;
          break;
        case 6:
          Aweeknum[6]=Aweeknum[6]+1;
          break;
        default:
          print("週のリスト作るところでエラー");
      }

    }
    Autofiles=itizilist;
    print("$Aweeknumこれが一週間のリスト");
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        NoiseCard(


          
          subTitle1: '最大dB値(dB)',
          subTitle2: '検知回数(回)',
          subTitle3: '',
          Maxdb: Maxdb,
          Sumfile: SumFile,
        ),
        // Rest of your code...
        SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            height: 700.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 影の色と透明度
                  spreadRadius: 1.0, // 影の広がり
                  blurRadius: 1.0, // 影のぼかし
                  offset: Offset(0, 0), // 影の位置 (x, y)

                ),
              ],
            ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "過去７日間",
                        style: TextStyle(fontSize: 30.0, color: Color.fromRGBO(0, 24, 88, 1)),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '以下のグラフは、過去７日間の検知回数のデータです。',
                          style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(0, 24, 88, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BarChart(

                          BarChartData(

                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(y: Aweeknum[6].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(y: Aweeknum[5].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(y: Aweeknum[4].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(y: Aweeknum[3].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 4, barRods: [BarChartRodData(y: Aweeknum[2].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 5, barRods: [BarChartRodData(y: Aweeknum[1].toDouble(), colors: [Colors.blue])]),
                              BarChartGroupData(x: 6, barRods: [BarChartRodData(y: Aweeknum[0].toDouble(), colors: [Colors.blue])]),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: SideTitles(
                                showTitles: true,
                                //getTitles: (value) {
                                 // if (value % 5 == 0) {
                                 //   return value.toInt().toString();
                                 // } else {
                                 //   return '';
                                 // }
                                //},

                              ),

                              bottomTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitles: (value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return '6日前';
                                    case 1:
                                      return '5日前';
                                    case 2:
                                      return '4日前';
                                    case 3:
                                      return '3日前';
                                    case 4:
                                      return '一昨日';
                                    case 5:
                                      return '昨日';
                                    case 6:
                                      return '今日';
                                    default:
                                      return '';
                                  }
                                },
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            gridData: FlGridData(show: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
    );
  }}

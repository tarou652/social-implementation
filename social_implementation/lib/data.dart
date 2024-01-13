import 'package:SI/components/footer.dart';
import 'package:flutter/material.dart';
import 'package:SI/components/header.dart';
import 'package:fl_chart/fl_chart.dart';

////////////////////////////////////////////////////////////////

void main() {
  runApp(DataPage());
}


class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('騒音対策'),
        ),
        body: SingleChildScrollView(
          child: AppBody(),
        ),
      ),
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
class AppBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(254, 246, 228, 1),
      //padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          NoiseCard(
            title: '昨夜の睡眠dB値',
            subTitle1: '最大dB値(dB)',
            subTitle2: '検知回数(回)',
            subTitle3: '',
          ),
          SizedBox(height: 16.0),
          SevenDaysChart(title: '過去7日間'),
          SizedBox(height: 16.0),
          Footer(currentIndex: 2, context: context,selected:0),
        ],
      ),
    );
  }
}

class NoiseCard extends StatelessWidget {
  final String title;
  final String subTitle1;
  final String subTitle2;
  final String subTitle3;

  const NoiseCard({
    required this.title,
    required this.subTitle1,
    required this.subTitle2,
    required this.subTitle3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 300.0,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
          
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 30.0, color: Color.fromRGBO(0, 24, 88, 1)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 200.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                             child: Text(
                                subTitle1,
                                style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(0, 24, 88, 1)),

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
                                        subTitle3,
                                        style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(0, 24, 88, 1)),
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
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 200.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subTitle2,
                              style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(0, 24, 88, 1)),
                            ),
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
      ),
    );
  }
}








//以下がグラフのコード
class SevenDaysChart extends StatelessWidget {
  final String title;

  const SevenDaysChart({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 700.0,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 30.0, color: Color.fromRGBO(0, 24, 88, 1)),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '以下のグラフは、過去７日間の最大dB値のデータです。睡眠時の音の基準値は40dBです',
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
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(y: 3, colors: [Colors.blue])]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(y: 1, colors: [Colors.blue])]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(y: 2, colors: [Colors.blue])]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(y: 3, colors: [Colors.blue])]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(y: 4, colors: [Colors.blue])]),
                      BarChartGroupData(x: 5, barRods: [BarChartRodData(y: 5, colors: [Colors.blue])]),
                      BarChartGroupData(x: 6, barRods: [BarChartRodData(y: 6, colors: [Colors.blue])]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(showTitles: true),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitles: (value) {
                          switch (value.toInt()) {
                            case 0:
                              return '7日前';
                            case 1:
                              return '6日前';
                            case 2:
                              return '5日前';
                            case 3:
                              return '4日前';
                            case 4:
                              return '3日前';
                            case 5:
                              return '一昨日';
                            case 6:
                              return '昨日';
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
    );
  }
}

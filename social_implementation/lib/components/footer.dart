import 'package:SI/history.dart';
import 'package:SI/main.dart';
import 'package:flutter/material.dart';
import 'package:SI/setting.dart';
import 'package:SI/data.dart';
class Footer extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final BuildContext context;
  final int selected ;
  Footer({required this.currentIndex, required this.context, required this.selected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) {
        // インデックスに基づいて画面を遷移する
        if (index == 0) {
          // 録音画面に遷移
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Myapp(),
            ),
          );
        } else if (index == 1) {
          // 設定画面に遷移
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingPage(),
            ),
          );
        } else if (index == 2) {
          // 履歴画面に遷移
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DataPage(),
            ),
          );
        }
        // else if (index == 3) {
        //   // 解析画面に遷移
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) => DataPage(),
        //     ),
        //   );
        // }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_circle_right),
          activeIcon: Icon(Icons.arrow_circle_right),
          label: '録音',
          backgroundColor: Color.fromRGBO(254, 246, 228, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_alarm),
          activeIcon: Icon(Icons.access_alarm),
          label: '設定',
          backgroundColor: Color.fromRGBO(254, 246, 228, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dehaze),
          activeIcon: Icon(Icons.dehaze),
          label: '履歴',
          backgroundColor: Color.fromRGBO(254, 246, 228, 1),
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.build),
        //   activeIcon: Icon(Icons.build),
        //   label: '解析',
        //   backgroundColor: Color.fromRGBO(254, 246, 228, 1),
        // ),
      ],

      type: BottomNavigationBarType.fixed,
      // ここで色を設定していても、shiftingにしているので
      // Itemの方のbackgroundColorが勝ちます。
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      enableFeedback: true,
      // IconTheme系統の値が優先されます。
      iconSize: 18,
      // 横向きレイアウトは省略します。
      // landscapeLayout: 省略
      selectedFontSize: 20,
      selectedIconTheme: selected == 0
          ? const IconThemeData(size: 30, color: Color.fromRGBO(0, 24, 88, 1))
          : const IconThemeData(size: 30, color: Color.fromRGBO(245, 130, 174, 1)),
      selectedLabelStyle: const TextStyle(color: Color.fromRGBO(0, 24, 88, 1)),
      // ちなみに、LabelStyleとItemColorの両方を選択した場合、ItemColorが勝ちます。
      selectedItemColor: selected == 0 ? Color.fromRGBO(0, 24, 88, 1) : Color.fromRGBO(245, 130, 174, 1),
      unselectedFontSize: 15,
      unselectedIconTheme: const IconThemeData(
          size: 25, color: Color.fromRGBO(245, 130, 174, 1)),
      unselectedLabelStyle:
          const TextStyle(color: Color.fromRGBO(245, 130, 174, 1)),
      // IconTheme系統の値が優先されるのでこの値は適応されません。
      unselectedItemColor: Color.fromRGBO(245, 130, 174, 1),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

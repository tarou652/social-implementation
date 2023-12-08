import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  Header({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:Color.fromRGBO(254, 246, 228, 1) ,
      title: Text(text,style: TextStyle(color:Color.fromRGBO(0, 24, 88, 1)),),
      actions: [Icon(Icons.add)],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
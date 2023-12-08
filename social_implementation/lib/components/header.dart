import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  Header({required this.text});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(254, 246, 228, 1),
      title: Text(
        text,
        style: TextStyle(color: Color.fromRGBO(0, 24, 88, 1)),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DataPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

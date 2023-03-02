import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scheduleme_application/screens/Chat/chat.dart';
import 'package:scheduleme_application/screens/Home/home.dart';
import 'package:scheduleme_application/screens/Profile/profile_display.dart';
import 'package:scheduleme_application/screens/Schedule/schedule.dart';

class MainBottom extends StatefulWidget {
  const MainBottom({super.key});

  @override
  State<MainBottom> createState() => _MainBottomState();
}

class _MainBottomState extends State<MainBottom> {
  int selectedIndex = 0;
  Color selectItemColor = Color(0xff88889D);

  final pageList = [
    const HomeScreen(),
    const ScheduleScreen(),
    const ChatScreen(),
    const ProfileDisplayScreen()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pageList.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.home,
              color: selectedIndex == 0 ? Color(0xff392AAB) : selectItemColor,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.calendar_month_outlined,
              color: selectedIndex == 1 ? Color(0xff392AAB) : selectItemColor,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.messenger_outline_rounded,
              color: selectedIndex == 2 ? Color(0xff392AAB) : selectItemColor,
            ),
          ),
          BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.person,
                color: selectedIndex == 3 ? Color(0xff392AAB) : selectItemColor,
              ))
        ],
        type: BottomNavigationBarType.shifting,
        currentIndex: selectedIndex,
        iconSize: 25,
        onTap: onItemTapped,
        elevation: 2,
      ),
    );
  }
}

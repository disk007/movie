import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/trending.dart';
import 'package:flutter_application_1/page/popular.dart';
import 'package:flutter_application_1/page/upcoming.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[ // เก็บ วิดเจ็ด ไว้ในตัวแปร เพื่อนำไปแสดง
    Trending(),
    Popular(),
    Upcoming(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex), // เปลี่ยนหน้าเมื่อเลือกเมนู
      ),
      bottomNavigationBar: BottomNavigationBar( // bottom navigation bar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Popular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Upcoming',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 38, 104, 227),
        onTap: _onItemTapped, // เมื่อกดเลือกเมนู ไปเรียก _onItemTapped
      ),
    );
  }
}

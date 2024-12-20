import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uangkoo/models/database.dart';
import 'package:uangkoo/pages/category_page.dart';
import 'package:uangkoo/pages/home_page.dart';
import 'package:uangkoo/pages/transaction_page.dart';
import 'package:uangkoo/pages/perofil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  final database = AppDb();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    currentIndex = 0;
    _children = [
      HomePage(selectedDate: selectedDate),
      const CategoryPage(),
    ];
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      if (index != 2) {
        _children = [
          HomePage(selectedDate: selectedDate),
          const CategoryPage(),
        ];
      }
    });
  }

  void onTabTapped(int index) {
    if (index == 2) {
      // Navigate to UserProfilePage
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const UserProfilePage(),
      ));
    } else {
      updateView(index, DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: (currentIndex == 0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) =>
                  const TransactionPage(transactionsWithCategory: null),
            ))
                .then((value) {
              setState(() {
                updateView(0, DateTime.now());
              });
            });
          },
          backgroundColor: Colors.blue,
          focusColor: Colors.white,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => onTabTapped(0),
              color: Colors.black,
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () => onTabTapped(1),
              color: Colors.black,
              icon: const Icon(Icons.list),
            ),
            IconButton(
              onPressed: () => onTabTapped(2),
              color: Colors.black,
              icon: const Icon(Icons.person),
            ),
          ],
        ),
      ),
      body: currentIndex == 2
          ? Container() // Placeholder for UserProfilePage
          : _children[currentIndex],
      appBar: (currentIndex == 1)
          ? PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: Text(
                  "Categories",
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              ),
            )
          : CalendarAppBar(
              fullCalendar: true,
              backButton: false,
              accent: Colors.blue,
              locale: 'en',
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              lastDate: DateTime.now(),
            ),
    );
  }
}

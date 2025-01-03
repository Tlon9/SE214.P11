import 'package:flutter/material.dart';
import 'package:travelowkey/bloc/explore/ExploreBloc.dart';
import 'package:travelowkey/repositories/exploreResult_repository.dart';
import 'package:travelowkey/screens/home/home_screens.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryBloc.dart';
import 'package:travelowkey/repositories/paymentHistory_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomePage(),
          // ExplorePage(),
          BlocProvider(
            create: (context) => ExploreBloc(
              repository: ExploreRepository(
                dataProvider: ExploreDataProvider(),
              ),
              queryArea: ""
            ),
            child: ExplorePage(),
          ),
          // NotificationScreen(),
          BlocProvider(
            create: (context) => PaymentHistoryBloc(
              repository: PaymentHistoryRepository(
                dataProvider: PaymentDataProvider(),
              ),
            ),
            child: HistoryPage(),
          ),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

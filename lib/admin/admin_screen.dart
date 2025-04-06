import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:changup_mk4/shared//search_screen.dart';
import 'manage_property_screen.dart';
import 'user_management_screen.dart';
import 'admin_my_page_screen.dart';

class AdminScreen extends StatefulWidget {
  final String userID; // userID 추가

  AdminScreen({required this.userID}); // userID 추가

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 2;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SearchScreen(userID: widget.userID), // 검색 화면
      ManageScreen(), // 관리 화면
      AdminHomeScreen(userID: widget.userID, updateTabIndex: _updateTabIndex), // 홈 화면
      UserManagementScreen(), // 유저 관리 화면
      AdminMyPageScreen(userID: widget.userID), // 마이페이지 화면
    ];
  }

  void _updateTabIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 2) {
          setState(() {
            _currentIndex = 2;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _updateTabIndex(index);
          },
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: '관리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '유저관리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  final String userID;
  final Function(int) updateTabIndex;

  AdminHomeScreen({required this.userID, required this.updateTabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("관리자 홈"), // 홈 화면의 AppBar 제목
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 등록된 매물 섹션
            Text(
              "오늘 등록된 매물",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildTodayPropertiesCount(),
            SizedBox(height: 24),

            // 기능으로 이동하는 버튼들
            Text(
              "관리자 기능",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildFeatureButton(
              context,
              "검색",
              Icons.search,
              Colors.green,
                  () {
                // 검색 기능 화면으로 이동 (네비게이션 바 유지)
                updateTabIndex(0);
              },
            ),
            _buildFeatureButton(
              context,
              "매물 관리",
              Icons.manage_accounts,
              Colors.orange,
                  () {
                // 매물 관리 화면으로 이동 (네비게이션 바 유지)
                updateTabIndex(1);
              },
            ),
            _buildFeatureButton(
              context,
              "유저 관리",
              Icons.people,
              Colors.blue,
                  () {
                // 유저 관리 화면으로 이동 (네비게이션 바 유지)
                updateTabIndex(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayPropertiesCount() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('properties')
          .where('timestamp', isGreaterThanOrEqualTo: _startOfToday())
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('오류가 발생했습니다: ${snapshot.error}');
        }

        final int count = snapshot.data?.docs.length ?? 0;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "오늘 등록된 매물 개수",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "$count 건",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: onPressed,
      ),
    );
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

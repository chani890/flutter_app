import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:changup_mk4/shared/search_screen.dart';
import 'package:changup_mk4/tenant/chat_list_screen.dart';
import 'package:changup_mk4/tenant/favorite_screen.dart';
import 'package:changup_mk4/tenant/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:changup_mk4/shared/property_detail_screen.dart';

class TenantScreen extends StatefulWidget {
  final String userID;

  TenantScreen({required this.userID});

  @override
  _TenantScreenState createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  int _currentIndex = 2; // 홈 화면이 기본값

  late final List<Widget> _screens; // userID를 포함한 화면 리스트 초기화

  @override
  void initState() {
    super.initState();
    _screens = [
      SearchScreen(userID: widget.userID), // 검색 화면
      FavoritesScreen(userID: widget.userID), // 즐겨찾기 화면
      TenantHomeScreen(userID: widget.userID), // 홈 화면
      ChatListScreen(userID: widget.userID), // 채팅 리스트 화면
      ProfileScreen(userID: widget.userID), // 프로필 화면
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 2) {
      setState(() {
        _currentIndex = 2;
      });
      return false; // 뒤로 가지 않음
    }
    return true; // 앱 종료 또는 이전 동작
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '즐겨찾기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '채팅',
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

class TenantHomeScreen extends StatelessWidget {
  final String userID;

  TenantHomeScreen({required this.userID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("부동산 중개 앱"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 창
            GestureDetector(
              onTap: () {
                // 검색 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(userID: userID),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "검색어를 입력하세요...",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // 최근 본 매물 섹션
            Text(
              "최근 본 매물",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 50, color: Colors.blue),
                        SizedBox(height: 8),
                        Text("매물 $index", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // 찜 목록 섹션
            Text(
              "찜 목록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Firestore에서 찜 목록 가져오기
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .doc(userID)
                  .collection('properties')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('오류가 발생했습니다: ${snapshot.error}'),
                  );
                }

                final favorites = snapshot.data?.docs ?? [];
                if (favorites.isEmpty) {
                  return Center(child: Text('찜한 매물이 없습니다.'));
                }

                return Column(
                  children: favorites.map((doc) {
                    final property = doc.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        // 클릭 시 상세정보 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(
                              property: property,
                              userID: userID,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, size: 50, color: Colors.red),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${property['complexName'] ?? '단지명 없음'} ${property['buildingNumber'] != null ?
                                  '${property['buildingNumber']}동' : '동 없음'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

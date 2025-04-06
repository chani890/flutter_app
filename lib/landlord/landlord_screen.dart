import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:changup_mk4/shared/search_screen.dart';
import 'register_screen.dart';
import 'manage_screen.dart';
import 'agent_chat_list_screen.dart';
import 'my_page_screen.dart';

class LandlordScreen extends StatefulWidget {
  final String userID;

  LandlordScreen({required this.userID});

  @override
  _LandlordScreenState createState() => _LandlordScreenState();
}

class _LandlordScreenState extends State<LandlordScreen> {
  int _currentIndex = 2;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RegisterScreen(userID: widget.userID), // 매물 등록 화면
      SearchScreen(userID: widget.userID), // 검색 화면
      LandlordScreenMain(userID: widget.userID), // 메인 홈 화면
      AgentChatListScreen(brokerID: widget.userID), // 채팅 리스트 화면
      MyPageScreen(userID: widget.userID), // 마이페이지 화면
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 2
          ? AppBar(
        title: Text("부동산 중개 앱"),
        centerTitle: true,
      )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '매물 등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}

class LandlordScreenMain extends StatelessWidget {
  final String userID;

  LandlordScreenMain({required this.userID});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          GestureDetector(
          onTap: () {
            Navigator.push(
            context,
              MaterialPageRoute(builder: (context) => SearchScreen(userID: userID),
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
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ],
        ),
      ),
    ),
    SizedBox(height: 24),
    // 내 매물 관리 제목과 편집 버튼
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    "내 매물 관리",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    TextButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ManageScreen(),
    ),
    );
    },
    child: Text(
    "편집",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
    ),
    ),
    ],
    ),
    SizedBox(height: 12),
    StreamBuilder<QuerySnapshot>(
    stream: ManageScreen.getUserPropertiesStream(userID),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(child: Text('등록된 매물이 없습니다.'));
    }
    return ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    final property = snapshot.data!.docs[index].data() as Map<String, dynamic>;
    final propertyType = property['propertyType'] ?? '아파트';
    final complexName = property['complexName'] ?? '단지명 없음';
    final buildingNumber = property['buildingNumber'] ?? '동 없음';
    final iconAsset = propertyType == '아파트'
    ? 'assets/house_icon.png'
        : 'assets/office_building_icon.png';

    return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey[300]!),
    ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 이미지 아이콘
          Image.asset(
            iconAsset,
            width: 80, // 크기 조정
            height: 80, // 크기 조정
            fit: BoxFit.cover,
          ),
          SizedBox(width: 16),
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$complexName, $buildingNumber',
                  style: TextStyle(
                    fontSize: 18, // 글자 크기 키움
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  propertyType,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    },
    );
    },
    ),
          ],
      ),
    );
  }
}



// Placeholder for chat and profile screens
class PlaceholderWidget extends StatelessWidget {
  final String message;

  PlaceholderWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

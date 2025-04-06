import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:changup_mk4/tenant/chat_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  final String userID;
  final bool isAdmin;

  PropertyDetailScreen({required this.property, required this.userID, this.isAdmin = false});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteState();
  }

  // 찜 상태 초기화
  Future<void> _initializeFavoriteState() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(widget.userID)
          .collection('properties')
          .doc(widget.property['propertyID']);

      final doc = await docRef.get();
      if (doc.exists) {
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      print('Error initializing favorite state: $e');
    }
  }

  // 채팅 시작 함수
  Future<void> _startChat(BuildContext context) async {
    String brokerID = widget.property['ownerId'] ?? ''; // 매물 소유자 ID 가져오기
    String propertyId = widget.property['propertyId'] ?? '';

    print('BrokerID: $brokerID');
    print('PropertyID: $propertyId');

    if (brokerID.isEmpty || propertyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효하지 않은 매물 정보입니다. 다시 시도해 주세요.')),
      );
      return;
    }

    String chatID = '${brokerID}_${widget.userID}_$propertyId';

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatID);

    // chats 문서가 이미 존재하는지 확인
    final chatExists = (await chatRef.get()).exists;

    if (!chatExists) {
      // chats 컬렉션에 문서 생성
      await chatRef.set({
        'users': [brokerID, widget.userID], // 중개인과 임차인의 ID 배열 추가
        'propertyId': propertyId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }

    // 채팅 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatID: chatID, userID: widget.userID),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      appBar: AppBar(
        title: Text("매물 상세 정보"),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              Icons.chat,
              color: widget.isAdmin ? Colors.grey : Colors.blueAccent,
            ),
            onPressed: widget.isAdmin ? null : () => _startChat(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/house_icon.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "가격: ${property['price']}원",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16),
            _buildPropertyDetailRow("도", property['province']),
            _buildPropertyDetailRow("시/군/구", property['city']),
            _buildPropertyDetailRow("도로명 주소", property['streetAddress']),
            _buildPropertyDetailRow("단지명", property['complexName']),
            _buildPropertyDetailRow("동", property['buildingNumber']),
            _buildPropertyDetailRow("유닛 번호", property['unitNumber']),
            _buildPropertyDetailRow("면적", "${property['area']} ㎡"),
            _buildPropertyDetailRow("방 개수", property['rooms'].toString()),
            _buildPropertyDetailRow("화장실 개수", property['bathrooms'].toString()),
            SizedBox(height: 24),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              "상세 설명",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              property['description'] ?? '상세 설명 없음',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$title:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '정보 없음',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 즐겨찾기 토글
  void _toggleFavorite() {
    if (isFavorite) {
      _removeFromFavorites();
    } else {
      _addToFavorites();
    }
  }

  // Firestore에 즐겨찾기 추가
  Future<void> _addToFavorites() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(widget.userID)
          .collection('properties')
          .doc(widget.property['propertyID']);

      await docRef.set(widget.property);
      setState(() {
        isFavorite = true;
      });
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Firestore에서 즐겨찾기 제거
  Future<void> _removeFromFavorites() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(widget.userID)
          .collection('properties')
          .doc(widget.property['propertyID']);

      await docRef.delete();
      setState(() {
        isFavorite = false;
      });
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}

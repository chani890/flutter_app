import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:changup_mk4/shared/property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userID;

  FavoritesScreen({required this.userID});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Set<String> _selectedItems = {}; // 선택된 매물 ID를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("찜 목록"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedItems.isEmpty
                ? null // 선택된 항목이 없으면 비활성화
                : _deleteSelectedItems,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(widget.userID)
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

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final propertyData = favorites[index].data() as Map<String, dynamic>;
              final propertyID = favorites[index].id;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Checkbox(
                    value: _selectedItems.contains(propertyID),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedItems.add(propertyID);
                        } else {
                          _selectedItems.remove(propertyID);
                        }
                      });
                    },
                  ),
                  title: Text(
                    '${propertyData['complexName'] ?? '단지명 없음'} ${propertyData['buildingNumber'] != null ?
                    '${propertyData['buildingNumber']}동' : '동 없음'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // 매물 상세 정보 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailScreen(
                          property: propertyData,
                          userID: widget.userID,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 선택된 항목 삭제
  Future<void> _deleteSelectedItems() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final propertyID in _selectedItems) {
        final docRef = FirebaseFirestore.instance
            .collection('favorites')
            .doc(widget.userID)
            .collection('properties')
            .doc(propertyID);

        batch.delete(docRef); // 선택된 항목 삭제
      }

      await batch.commit(); // Firestore 배치 작업 실행

      setState(() {
        _selectedItems.clear(); // 선택 항목 초기화
      });
    } catch (e) {
      print('Error deleting selected items: $e');
    }
  }
}

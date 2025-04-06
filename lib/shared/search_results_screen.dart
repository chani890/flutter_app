import 'package:flutter/material.dart';
import 'property_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String? userID;

  SearchResultsScreen({required this.searchResults, this.userID});

  // 층수 정보 추출
  String _extractFloorFromUnit(String unitNumber) {
    if (unitNumber.length >= 3) {
      return "${unitNumber.substring(0, unitNumber.length - 2)}층";
    }
    return "층수 정보 없음";
  }

  // 거래 유형에 따른 가격 라벨
  String _getPriceLabel(String transactionType) {
    switch (transactionType) {
      case '매매':
        return '매매가';
      case '전세':
        return '전세가';
      case '월세':
        return '월세가';
      default:
        return '가격';
    }
  }

  // 매물 유형에 따른 이미지 설정
  String _getPropertyImage(String propertyType) {
    return propertyType == '오피스텔'
        ? 'assets/office_building_icon.png'
        : 'assets/house_icon.png';
  }

  @override
  Widget build(BuildContext context) {
    final String resolvedUserID = userID ?? 'guest'; // null 처리: 기본값 'guest'
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: searchResults.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Text(
              '다른 검색어를 입력해 보세요.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final property = searchResults[index];
          final floor = _extractFloorFromUnit(property['unitNumber'] ?? '');
          final priceLabel = _getPriceLabel(property['transactionType'] ?? '');
          final image = _getPropertyImage(property['propertyType'] ?? '');
          final buildingInfo = property['buildingNumber'] != null && property['buildingNumber'] != ''
              ? "${property['complexName']} ${property['buildingNumber']}동"
              : property['streetAddress'] ?? "주소 정보 없음";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(
                    property: property,  // 매물 객체 전달
                    userID: resolvedUserID,  // null 처리된 사용자 ID 전달
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: Image.asset(
                  image,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
                title: Text(
                  buildingInfo,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "층수: $floor",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      "$priceLabel: ${property['price']}원",
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                    Text(
                      "상태: ${property['status'] ?? '상태 없음'}",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

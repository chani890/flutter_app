import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landlord_screen.dart'; // 임대인 화면 파일을 임포트합니다.

class RegisterScreen extends StatefulWidget {
  final String userID;

  RegisterScreen({required this.userID});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? propertyType;
  String? transactionType;

  String? selectedDo;
  String? selectedSiGunGu;

  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController complexNameController = TextEditingController();
  final TextEditingController buildingNumberController = TextEditingController();
  final TextEditingController unitNumberController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final List<String> doOptions = [
    '서울특별시', '부산광역시', '대구광역시', '인천광역시', '광주광역시', '대전광역시', '울산광역시', '세종특별자치시',
    '경기도', '강원도', '충청북도', '충청남도', '전라북도', '전라남도', '경상북도', '경상남도', '제주특별자치도'
  ];

  final Map<String, List<String>> siGunGuMap = {
    '서울특별시': ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'],
    '부산광역시': ['강서구', '금정구', '기장군', '남구', '동구', '동래구', '부산진구', '북구', '사상구', '사하구', '서구', '수영구', '연제구', '영도구', '중구', '해운대구'],
    '대구광역시': ['남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구'],
    '인천광역시': ['강화군', '계양구', '미추홀구', '남동구', '동구', '부평구', '서구', '연수구', '중구'],
    '광주광역시': ['광산구', '남구', '동구', '북구', '서구'],
    '대전광역시': ['대덕구', '동구', '서구', '유성구', '중구'],
    '울산광역시': ['남구', '동구', '북구', '울주군', '중구'],
    '세종특별자치시': ['세종시 전 지역'],
    '경기도': ['가평군', '고양시 덕양구', '고양시 일산동구', '고양시 일산서구', '과천시', '광명시', '광주시', '구리시', '군포시', '김포시', '남양주시', '동두천시', '부천시', '성남시 분당구', '성남시 수정구', '성남시 중원구', '수원시 권선구', '수원시 영통구', '수원시 장안구', '수원시 팔달구', '시흥시', '안산시 단원구', '안산시 상록구', '안성시', '안양시 동안구', '안양시 만안구', '양주시', '양평군', '여주시', '연천군', '오산시', '용인시 기흥구', '용인시 수지구', '용인시 처인구', '의왕시', '의정부시', '이천시', '파주시', '평택시', '포천시', '하남시', '화성시'],
    '강원도': ['강릉시', '고성군', '동해시', '삼척시', '속초시', '양구군', '양양군', '영월군', '원주시', '인제군', '정선군', '철원군', '춘천시', '태백시', '평창군', '홍천군', '화천군', '횡성군'],
    '충청북도': ['괴산군', '단양군', '보은군', '영동군', '옥천군', '음성군', '제천시', '진천군', '청주시 상당구', '청주시 서원구', '청주시 청원구', '청주시 흥덕구', '충주시'],
    '충청남도': ['계룡시', '공주시', '금산군', '논산시', '당진시', '보령시', '부여군', '서산시', '서천군', '아산시', '예산군', '천안시 동남구', '천안시 서북구', '청양군', '태안군', '홍성군'],
    '전라북도': ['고창군', '군산시', '김제시', '남원시', '무주군', '부안군', '순창군', '완주군', '익산시', '임실군', '장수군', '전주시 덕진구', '전주시 완산구', '정읍시', '진안군'],
    '전라남도': ['강진군', '고흥군', '곡성군', '광양시', '구례군', '나주시', '담양군', '목포시', '무안군', '보성군', '순천시', '신안군', '여수시', '영광군', '영암군', '완도군', '장성군', '장흥군', '진도군', '함평군', '해남군', '화순군'],
    '경상북도': ['경산시', '경주시', '고령군', '구미시', '군위군', '김천시', '문경시', '봉화군', '상주시', '성주군', '안동시', '영덕군', '영양군', '영주시', '영천시', '예천군', '울릉군', '울진군', '의성군', '청도군', '청송군', '칠곡군', '포항시 남구', '포항시 북구'],
    '경상남도': ['거제시', '거창군', '고성군', '김해시', '남해군', '밀양시', '사천시', '산청군', '양산시', '의령군', '진주시', '창녕군', '창원시 마산합포구', '창원시 마산회원구', '창원시 성산구', '창원시 의창구', '창원시 진해구', '통영시', '하동군', '함안군', '함양군', '합천군'],
    '제주특별자치도': ['제주시', '서귀포시']
  };

  Future<void> _submitProperty() async {
    if (transactionType == null || selectedDo == null || selectedSiGunGu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해 주세요.')),
      );
      return;
    }

    String complexName = complexNameController.text.trim();
    String streetAddress = streetAddressController.text.trim();
    String unitNumber = unitNumberController.text.trim();
    String buildingNumber = buildingNumberController.text.trim();
    String area = areaController.text.trim();
    String rooms = roomsController.text.trim();
    String bathrooms = bathroomsController.text.trim();
    String price = priceController.text.trim();
    String description = descriptionController.text.trim();

    if (complexName.isEmpty || streetAddress.isEmpty || unitNumber.isEmpty || buildingNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;

      // Step 1: blockList에 임시 등록
      DocumentReference blockRef = _firestore.collection('blockList').doc();
      await blockRef.set({
        'complexName': complexName,
        'streetAddress': streetAddress,
        'unitNumber': unitNumber,
        'buildingNumber': buildingNumber,
        'timestamp': FieldValue.serverTimestamp(), // 등록 시간 기록
      });

      // Step 2: 중복 매물 확인
      QuerySnapshot querySnapshot = await _firestore
          .collection('blockList')
          .where('complexName', isEqualTo: complexName)
          .where('streetAddress', isEqualTo: streetAddress)
          .where('unitNumber', isEqualTo: unitNumber)
          .where('buildingNumber', isEqualTo: buildingNumber)
          .get();

      if (querySnapshot.docs.length > 1) {
        // 동일한 매물이 이미 존재한다면 (임시 등록된 것을 제외한 다른 문서가 있을 때)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 매물은 24시간 이내에 재등록할 수 없습니다.')),
        );
        return;
      }

      // Step 3: 중복이 없다면 최종 등록 (properties 컬렉션에 추가)
      DocumentReference docRef = await _firestore.collection('properties').add({
        'propertyType': propertyType,
        'transactionType': transactionType,
        'province': selectedDo,
        'city': selectedSiGunGu,
        'streetAddress': streetAddress,
        'complexName': complexName,
        'buildingNumber': buildingNumber,
        'unitNumber': unitNumber,
        'area': area,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'price': price,
        'description': description,
        'ownerId': userId,
        'status': 'available',
        'createdAt': Timestamp.now(),
      });

      await docRef.update({'propertyId': docRef.id});

      // Step 4: blockList에서 임시 등록된 문서 삭제
      await blockRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물이 성공적으로 등록되었습니다!')),
      );

      _clearFields();

      Navigator.pushReplacement(
        context,
          MaterialPageRoute(builder: (context) => LandlordScreen(userID: widget.userID))
      );

    } catch (e) {
      // 중복으로 인해 등록이 거부되면 blockList에서 임시 등록된 문서를 삭제
      await _firestore
          .collection('blockList')
          .where('complexName', isEqualTo: complexName)
          .where('streetAddress', isEqualTo: streetAddress)
          .where('unitNumber', isEqualTo: unitNumber)
          .where('buildingNumber', isEqualTo: buildingNumber)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 등록 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _clearFields() {
    streetAddressController.clear();
    complexNameController.clear();
    buildingNumberController.clear();
    unitNumberController.clear();
    areaController.clear();
    roomsController.clear();
    bathroomsController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      propertyType = null;
      transactionType = null;
      selectedDo = null;
      selectedSiGunGu = null;
    });
  }

  String getPriceLabel() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("매물 등록")),
      body: propertyType == null
          ? _buildPropertyTypeSelection()
          : transactionType == null
          ? _buildTransactionTypeSelection()
          : _buildPropertyForm(),
    );
  }

  Widget _buildPropertyTypeSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStyledButton(
            label: '아파트',
            onPressed: () {
              setState(() {
                propertyType = '아파트';
              });
            },
          ),
          SizedBox(height: 16),
          _buildStyledButton(
            label: '오피스텔',
            onPressed: () {
              setState(() {
                propertyType = '오피스텔';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStyledButton(
            label: '매매',
            onPressed: () {
              setState(() {
                transactionType = '매매';
              });
            },
          ),
          SizedBox(height: 16),
          _buildStyledButton(
            label: '전세',
            onPressed: () {
              setState(() {
                transactionType = '전세';
              });
            },
          ),
          SizedBox(height: 16),
          _buildStyledButton(
            label: '월세',
            onPressed: () {
              setState(() {
                transactionType = '월세';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        minimumSize: Size(200, 50),
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPropertyForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('매물 유형: $propertyType', style: TextStyle(fontSize: 18)),
            Text('거래 유형: $transactionType', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDo,
              items: doOptions.map((doOption) {
                return DropdownMenuItem(value: doOption, child: Text(doOption));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDo = value;
                  selectedSiGunGu = null;
                });
              },
              decoration: InputDecoration(labelText: "도"),
            ),
            if (selectedDo != null)
              DropdownButtonFormField<String>(
                value: selectedSiGunGu,
                items: (siGunGuMap[selectedDo] ?? []).map((siGunGu) {
                  return DropdownMenuItem(value: siGunGu, child: Text(siGunGu));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSiGunGu = value;
                  });
                },
                decoration: InputDecoration(labelText: "시/군/구"),
              ),
            TextField(
              controller: streetAddressController,
              decoration: InputDecoration(labelText: "상세 주소"),
            ),
            TextField(
              controller: complexNameController,
              decoration: InputDecoration(labelText: "단지 명"),
            ),
            TextField(
              controller: buildingNumberController,
              decoration: InputDecoration(
                labelText: "동 (선택사항)",
              ),
            ),
            TextField(
              controller: unitNumberController,
              decoration: InputDecoration(labelText: "호"),
            ),
            TextField(
              controller: areaController,
              decoration: InputDecoration(labelText: "면적 (㎡)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: roomsController,
              decoration: InputDecoration(labelText: "방 개수"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bathroomsController,
              decoration: InputDecoration(labelText: "화장실 개수"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: getPriceLabel()),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "상세 설명"),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProperty,
              child: Text("매물 등록"),
            ),
          ],
        ),
      ),
    );
  }
}
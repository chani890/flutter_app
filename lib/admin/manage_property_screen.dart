import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('매물 관리'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work,
                size: 100,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              Text(
                '매물 관리',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 아파트 매물 관리 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyListScreen(propertyType: '아파트'),
                    ),
                  );
                },
                child: Text('아파트'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 오피스텔 매물 관리 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyListScreen(propertyType: '오피스텔'),
                    ),
                  );
                },
                child: Text('오피스텔'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyListScreen extends StatelessWidget {
  final String propertyType;

  PropertyListScreen({required this.propertyType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$propertyType 관리'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('propertyType', isEqualTo: propertyType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          }

          final properties = snapshot.data?.docs ?? [];

          if (properties.isEmpty) {
            return Center(child: Text('등록된 $propertyType 매물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index].data() as Map<String, dynamic>;
              final propertyID = properties[index].id;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: Icon(Icons.home, color: Colors.blue),
                  title: Text(property['complexName'] ?? '단지 명 없음'),
                  subtitle: Text('가격: ${property['price']} 원'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      // 매물 수정 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyEditScreen(
                            propertyID: propertyID,
                            propertyData: property,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PropertyEditScreen extends StatefulWidget {
  final String propertyID;
  final Map<String, dynamic> propertyData;

  PropertyEditScreen({required this.propertyID, required this.propertyData});

  @override
  _PropertyEditScreenState createState() => _PropertyEditScreenState();
}

class _PropertyEditScreenState extends State<PropertyEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _priceController;
  late TextEditingController _complexNameController;
  late TextEditingController _addressController;
  late TextEditingController _buildingNumberController;
  late TextEditingController _unitNumberController;
  late TextEditingController _ownerIDController;
  late TextEditingController _descriptionController;
  late TextEditingController _statusController;
  late TextEditingController _areaController;
  late TextEditingController _roomsController;
  late TextEditingController _bathroomsController;

  @override
  void initState() {
    super.initState();
    _provinceController = TextEditingController(text: widget.propertyData['province']);
    _cityController = TextEditingController(text: widget.propertyData['city']);
    _priceController = TextEditingController(text: widget.propertyData['price'].toString());
    _complexNameController = TextEditingController(text: widget.propertyData['complexName']);
    _addressController = TextEditingController(text: widget.propertyData['address']);
    _buildingNumberController = TextEditingController(text: widget.propertyData['buildingNumber']);
    _unitNumberController = TextEditingController(text: widget.propertyData['unitNumber']);
    _ownerIDController = TextEditingController(text: widget.propertyData['ownerId']);
    _descriptionController = TextEditingController(text: widget.propertyData['description']);
    _statusController = TextEditingController(text: widget.propertyData['status'] ?? 'available');
    _areaController = TextEditingController(text: widget.propertyData['area'].toString());
    _roomsController = TextEditingController(text: widget.propertyData['rooms'].toString());
    _bathroomsController = TextEditingController(text: widget.propertyData['bathrooms'].toString());
  }

  Future<void> _updateProperty() async {
    try {
      await _firestore.collection('properties').doc(widget.propertyID).update({
        'province': _provinceController.text,
        'city': _cityController.text,
        'price': int.parse(_priceController.text),
        'complexName': _complexNameController.text,
        'address': _addressController.text,
        'buildingNumber': _buildingNumberController.text,
        'unitNumber': _unitNumberController.text,
        'ownerId': _ownerIDController.text,
        'description': _descriptionController.text,
        'status': _statusController.text,
        'area': double.parse(_areaController.text),
        'rooms': int.parse(_roomsController.text),
        'bathrooms': int.parse(_bathroomsController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 정보가 성공적으로 업데이트되었습니다.')),
      );
      Navigator.of(context).pop(); // 업데이트 후 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _deleteProperty() async {
    try {
      await _firestore.collection('properties').doc(widget.propertyID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물이 성공적으로 삭제되었습니다.')),
      );
      Navigator.of(context).pop(); // 삭제 후 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('매물 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: _provinceController, label: '도'),
              SizedBox(height: 16),
              _buildTextField(controller: _cityController, label: '시/군/구'),
              SizedBox(height: 16),
              _buildTextField(controller: _complexNameController, label: '단지명'),
              SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: '가격', inputType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(controller: _addressController, label: '주소'),
              SizedBox(height: 16),
              _buildTextField(controller: _buildingNumberController, label: '건물 번호'),
              SizedBox(height: 16),
              _buildTextField(controller: _unitNumberController, label: '유닛 번호'),
              SizedBox(height: 16),
              _buildTextField(controller: _ownerIDController, label: '소유자 ID'),
              SizedBox(height: 16),
              _buildTextField(controller: _descriptionController, label: '상세 설명', maxLines: 4),
              SizedBox(height: 16),
              _buildTextField(controller: _statusController, label: '상태'),
              SizedBox(height: 16),
              _buildTextField(controller: _areaController, label: '면적 (제곱미터)', inputType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(controller: _roomsController, label: '방 개수', inputType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(controller: _bathroomsController, label: '화장실 개수', inputType: TextInputType.number),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _updateProperty,
                  child: Text('매물 업데이트'),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _deleteProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text('매물 삭제'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: inputType,
    );
  }
}

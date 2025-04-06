import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:changup_mk4/shared/property_detail_screen.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 관리'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TenantListScreen(),
                    ),
                  );
                },
                child: Text('임차인 관리'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrokerListScreen(),
                    ),
                  );
                },
                child: Text('중개인 관리'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TenantListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('임차인 목록'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('userType', isEqualTo: 'tenant').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          }

          final tenants = snapshot.data?.docs ?? [];

          if (tenants.isEmpty) {
            return Center(child: Text('등록된 임차인이 없습니다.'));
          }

          return ListView.builder(
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index].data() as Map<String, dynamic>;
              final userID = tenants[index].id;

              return ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text(tenant['name'] ?? '이름 없음'),
                subtitle: Text(tenant['email'] ?? '이메일 없음'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteUser(userID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('임차인이 성공적으로 삭제되었습니다.')),
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

  Future<void> _deleteUser(String userID) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userID).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

class BrokerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('중개인 목록'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('userType', isEqualTo: 'agent' ).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          }

          final brokers = snapshot.data?.docs ?? [];

          if (brokers.isEmpty) {
            return Center(child: Text('등록된 중개인이 없습니다.'));
          }

          return ListView.builder(
            itemCount: brokers.length,
            itemBuilder: (context, index) {
              final broker = brokers[index].data() as Map<String, dynamic>;
              final userID = brokers[index].id;

              return ListTile(
                leading: Icon(Icons.business, color: Colors.green),
                title: Text(broker['name'] ?? '이름 없음'),
                subtitle: Text(broker['email'] ?? '이메일 없음'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrokerPropertyListScreen(brokerID: userID),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteUser(userID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('중개인이 성공적으로 삭제되었습니다.')),
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

  Future<void> _deleteUser(String userID) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userID).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

class BrokerPropertyListScreen extends StatelessWidget {
  final String brokerID;

  BrokerPropertyListScreen({required this.brokerID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('중개인의 매물 목록'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('properties').where('ownerId', isEqualTo: brokerID).snapshots(),
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
            return Center(child: Text('등록된 매물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index].data() as Map<String, dynamic>;
              final propertyID = properties[index].id;

              return ListTile(
                leading: Icon(Icons.home, color: Colors.blue),
                title: Text(property['complexName'] ?? '단지명 없음'),
                subtitle: Text('가격: ${property['price']}원'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailScreen(
                        property: property,
                        userID: brokerID,
                        isAdmin: false, // 중개인이기 때문에 관리자 모드가 아님
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditPropertyScreen extends StatefulWidget {
  final String propertyID;
  final Map<String, dynamic> propertyData;

  EditPropertyScreen({required this.propertyID, required this.propertyData});

  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _priceController;
  late TextEditingController _complexNameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.propertyData['price'].toString());
    _complexNameController = TextEditingController(text: widget.propertyData['complexName']);
    _addressController = TextEditingController(text: widget.propertyData['address']);
    _descriptionController = TextEditingController(text: widget.propertyData['description']);
  }

  Future<void> _updateProperty() async {
    try {
      await _firestore.collection('properties').doc(widget.propertyID).update({
        'price': int.parse(_priceController.text),
        'complexName': _complexNameController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 정보가 성공적으로 업데이트되었습니다.')),
      );
      Navigator.of(context).pop(); // 수정 후 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 수정 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('매물 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _complexNameController, label: '단지명'),
            SizedBox(height: 16),
            _buildTextField(controller: _priceController, label: '가격', inputType: TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: '주소'),
            SizedBox(height: 16),
            _buildTextField(controller: _descriptionController, label: '상세 설명', maxLines: 4),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateProperty,
                child: Text('매물 업데이트'),
              ),
            ),
          ],
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

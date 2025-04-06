import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editproperty_screen.dart';

class ManageScreen extends StatefulWidget {
  @override
  _ManageScreenState createState() => _ManageScreenState();

  static Stream<QuerySnapshot> getUserPropertiesStream(String userId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('properties')
        .where('ownerId', isEqualTo: userId)
        .snapshots();
  }
}

class _ManageScreenState extends State<ManageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? '';
  }

  Future<void> _deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물이 성공적으로 삭제되었습니다.')),
      );
    } catch (e) {
      print("Error deleting property: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  void _editProperty(String propertyId, Map<String, dynamic> propertyData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(
          propertyID: propertyId,
          propertyData: propertyData,
        ),
      ),
    );
  }

  Future<void> _updateStatus(String propertyId, String newStatus) async {
    try {
      await _firestore.collection('properties').doc(propertyId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('매물 상태가 성공적으로 업데이트되었습니다.')),
      );
    } catch (e) {
      print("Error updating status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("매물 관리")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ManageScreen.getUserPropertiesStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No registered properties."));
          }
          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String propertyId = doc.id;
              String currentStatus = data['status'] ?? 'available';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  title: Text(data['complexName'] ?? 'No complex name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(" ${data['buildingNumber'] ?? 'No address'}"),
                      Text("Status: $currentStatus"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProperty(propertyId, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProperty(propertyId),
                      ),
                      DropdownButton<String>(
                        value: currentStatus,
                        items: ['available', 'sold', 'rented']
                            .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                            .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null && newStatus != currentStatus) {
                            _updateStatus(propertyId, newStatus);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

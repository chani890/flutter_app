import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentChatScreen extends StatelessWidget {
  final String chatID;
  final String brokerID;

  AgentChatScreen({required this.chatID, required this.brokerID});

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(BuildContext context, String message) async {
    if (message.trim().isEmpty) return;

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .collection('messages');

    // 메시지 추가
    await messagesRef.add({
      'senderID': brokerID,
      'content': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 마지막 메시지 시간 업데이트
    await FirebaseFirestore.instance.collection('chats').doc(chatID).update({
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('chats').doc(chatID).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
              return Text('상대방 정보 불러오기 실패');
            }

            final chatData = snapshot.data?.data() as Map<String, dynamic>;
            final tenantID = chatData['users'][0] == brokerID ? chatData['users'][1] : chatData['users'][0];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(tenantID).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data?.data() == null) {
                  return Text('상대방 정보 불러오기 실패');
                }

                final tenantData = userSnapshot.data?.data() as Map<String, dynamic>;
                return Text(tenantData['name'] ?? '사용자 이름 없음');
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('chats').doc(chatID).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('매물 정보를 불러올 수 없습니다.'),
                  ),
                );
              }

              final chatData = snapshot.data?.data() as Map<String, dynamic>;
              final propertyID = chatData['propertyId'];

              if (propertyID == null || propertyID.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('매물 정보가 없습니다.'),
                  ),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('properties').doc(propertyID).get(),
                builder: (context, propertySnapshot) {
                  if (propertySnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (propertySnapshot.hasError || !propertySnapshot.hasData || propertySnapshot.data?.data() == null) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('매물 정보를 불러올 수 없습니다.'),
                      ),
                    );
                  }

                  final property = propertySnapshot.data?.data() as Map<String, dynamic>;
                  final String propertyType = property['type'] ?? 'unknown';
                  final String complexName = property['complexName'] ?? '단지명 없음';
                  final String buildingNumber = property['buildingNumber'] ?? '동 번호 없음';
                  final String imagePath = propertyType == '아파트' ? 'assets/house_icon.png' : 'assets/office_building_icon.png';

                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          imagePath,
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complexName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                buildingNumber,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatID)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderID'] == brokerID;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message['content']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: () => _sendMessage(context, _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

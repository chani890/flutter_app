import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatID;
  final String userID;

  ChatScreen({required this.chatID, required this.userID});

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(BuildContext context) async {
    if (_messageController.text.trim().isEmpty) return;

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .collection('messages');

    await messagesRef.add({
      'senderID': userID,
      'content': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the last message timestamp in the chat document
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

            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Text('상대방 정보 불러오기 실패');
            }

            final chatData = snapshot.data!.data() as Map<String, dynamic>?;
            if (chatData == null) {
              return Text('상대방 정보 불러오기 실패');
            }

            final brokerID = chatData['users'][0] == userID ? chatData['users'][1] : chatData['users'][0];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(brokerID).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Text('상대방 정보 불러오기 실패');
                }

                final brokerData = userSnapshot.data!.data() as Map<String, dynamic>?;
                return Text(brokerData?['name'] ?? '사용자 이름 없음');
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

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('매물 정보를 불러올 수 없습니다.'));
              }

              final chatData = snapshot.data!.data() as Map<String, dynamic>?;
              if (chatData == null) {
                return Center(child: Text('매물 정보를 불러올 수 없습니다.'));
              }

              final propertyID = chatData['propertyId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('properties').doc(propertyID).get(),
                builder: (context, propertySnapshot) {
                  if (propertySnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (propertySnapshot.hasError || !propertySnapshot.hasData || !propertySnapshot.data!.exists) {
                    return Center(child: Text('매물 정보를 불러올 수 없습니다.'));
                  }

                  final property = propertySnapshot.data!.data() as Map<String, dynamic>?;
                  if (property == null) {
                    return Center(child: Text('매물 정보를 불러올 수 없습니다.'));
                  }

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

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text('채팅 메시지를 불러올 수 없습니다.'));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>?;
                    if (message == null) {
                      return Container(); // Null 메시지의 경우 빈 컨테이너 반환
                    }
                    final isMe = message['senderID'] == userID;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
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
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

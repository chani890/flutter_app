import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'agent_chat_screen.dart'; // 중개인 채팅 화면 import

class AgentChatListScreen extends StatelessWidget {
  final String brokerID;

  AgentChatListScreen({required this.brokerID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("중개인 채팅 목록"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: brokerID) // users 배열에 brokerID가 포함된 채팅 가져옴
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("진행 중인 채팅이 없습니다."));
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatData = chatRooms[index].data() as Map<String, dynamic>;
              final users = chatData['users'] as List<dynamic>;
              final tenantID = users.firstWhere((id) => id != brokerID, orElse: () => '임차인 ID 없음');
              final chatID = chatRooms[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(tenantID).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("로딩 중..."),
                    );
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final tenantName = userData?['name'] ?? '이름 없음';

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatID)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (messageSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text("로딩 중..."),
                        );
                      }

                      if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                        return ListTile(
                          title: Text(tenantName),
                          subtitle: Text('메시지 없음'),
                        );
                      }

                      final lastMessageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                      final lastMessageContent = lastMessageData['content'] ?? '메시지 없음';

                      return ListTile(
                        title: Text('$tenantName'),
                        subtitle: Text(
                          '$lastMessageContent\n시간: ${lastMessageData['timestamp'] != null ? lastMessageData['timestamp'].toDate().toString() : '시간 없음'}',
                        ),
                        onTap: () {
                          // 채팅방으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgentChatScreen(
                                chatID: chatID,
                                brokerID: brokerID,
                              ),
                            ),
                          );
                        },
                      );
                    },
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

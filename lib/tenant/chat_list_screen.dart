import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String userID;

  ChatListScreen({required this.userID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅 목록"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("채팅방이 없습니다."));
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final chatData = chatRoom.data() as Map<String, dynamic>?;
              if (chatData == null) {
                return ListTile(title: Text("채팅방 데이터를 불러올 수 없습니다."));
              }

              final users = chatData['users'] as List<dynamic>;

              // 중개인과 임차인의 ID 중 나 자신이 아닌 상대방의 ID를 찾는다
              final otherUserID = users.firstWhere((id) => id != userID, orElse: () => '상대방 ID 없음');

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserID).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("로딩 중..."),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text("사용자 정보를 불러올 수 없습니다."),
                    );
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final otherUserName = userData?['name'] ?? '사용자 이름 없음';

                  // `chats` 문서의 `messages` 하위 컬렉션에서 마지막 메시지 가져오기
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatRoom.id)
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
                          title: Text(otherUserName),
                          subtitle: Text('메시지 없음'),
                        );
                      }

                      final lastMessageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>?;
                      if (lastMessageData == null) {
                        return ListTile(
                          title: Text(otherUserName),
                          subtitle: Text('메시지 없음'),
                        );
                      }

                      final lastMessageContent = lastMessageData['content'] ?? '메시지 없음';
                      final lastMessageTimestamp = lastMessageData['timestamp']?.toDate();

                      return ListTile(
                        title: Text(otherUserName),
                        subtitle: Text(
                          '마지막 메시지: $lastMessageContent\n시간: ${lastMessageTimestamp != null ? lastMessageTimestamp.toString() : '시간 없음'}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatID: chatRoom.id, userID: userID),
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login/login_screen.dart';  // 로그인 화면
import 'main_screen.dart';  // 비로그인 메인 화면
import 'shared/search_screen.dart';  // 검색 화면
import 'tenant/tenant_screen.dart';  // 임차인 화면
import 'tenant/chat_screen.dart';
import 'tenant/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '부동산 중개 앱',
      initialRoute: '/',  // 초기 화면 설정
      routes: {
        '/': (context) => MainScreen(),  // 비로그인 메인 화면
        '/login': (context) => LoginScreen(),  // 로그인 화면
        '/search': (context) => SearchScreen(userID: ''),  // 검색 화면 (userID 미리 비워둠)
        '/tenant': (context) => TenantScreen(userID: ''),  // 임차인 화면 (userID 미리 비워둠)
        '/chat-list': (context) => ChatListScreen(userID: ''),  // 채팅 목록 화면 (userID 미리 비워둠)
        // ChatScreen은 인자로 chatID와 userID를 받아야 하므로 RouteSettings를 통해 전달
        '/chat': (context) => ChatScreen(
          chatID: ModalRoute.of(context)!.settings.arguments as String,
          userID: '',
        ),  // 채팅 세부 화면
      },
    );
  }
}

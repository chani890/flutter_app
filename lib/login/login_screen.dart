import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:changup_mk4/landlord/landlord_screen.dart';
import 'package:changup_mk4/tenant/tenant_screen.dart';
import 'package:changup_mk4/admin/admin_screen.dart';      // 관리자 화면
import 'signup_screen.dart';                              // 회원가입 화면

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';

  // 사용자 유형에 따른 화면 이동 함수
  Future<void> _navigateBasedOnUserType(String uid) async {
    try {
      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      String userType = userDoc['userType'];

      // 사용자 유형에 따라 화면 이동
      if (userType == 'landlord' || userType == 'agent') {
        // 임대인과 중개인은 LandlordScreen으로 이동
        Navigator.pushReplacement(
          context,
            MaterialPageRoute(builder: (context) => LandlordScreen(userID: uid))
        );
      } else if (userType == 'tenant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TenantScreen(userID: uid)),
        );
      } else if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen(userID: uid)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알 수 없는 사용자 유형입니다.')),
        );
      }
    } catch (e) {
      print("Error fetching user type: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 유형을 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 화면'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Firebase Authentication을 사용해 로그인
                  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // 로그인 성공 시 Firestore에서 사용자 유형 확인 후 화면 이동
                  await _navigateBasedOnUserType(userCredential.user!.uid);
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인에 실패했습니다. 다시 시도하세요.')),
                  );
                }
              },
              child: Text('로그인'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 회원가입 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 정보 입력 필드
  String email = '';
  String password = '';
  String userId = ''; // 사용자 ID
  String userType = 'tenant'; // 기본값을 'tenant'로 설정 (영문으로 저장)
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ID 입력 필드
            TextField(
              decoration: InputDecoration(labelText: 'ID'),
              onChanged: (value) {
                setState(() {
                  userId = value;
                });
              },
            ),
            // 이메일 입력 필드
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            // 비밀번호 입력 필드
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            // 이름 입력 필드
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            // 사용자 유형 선택 드롭다운 메뉴
            DropdownButton<String>(
              value: userType,
              items: [
                DropdownMenuItem(value: 'tenant', child: Text('임차인')),
                DropdownMenuItem(value: 'agent', child: Text('중개인')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  userType = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            // 회원가입 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  // Firebase Authentication을 통해 이메일, 비밀번호로 사용자 생성
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // Firestore에 사용자 정보 저장 (userType을 영어 값으로 저장)
                  await _firestore.collection('users').doc(userCredential.user?.uid).set({
                    'userId': userId,     // 사용자 ID 저장
                    'email': email,       // 이메일 저장
                    'name': name,         // 이름 저장
                    'userType': userType, // 사용자 유형 저장 (영문으로 저장됨)
                  });

                  // 회원가입 완료 후 로그인 화면으로 이동
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  print("회원가입 실패: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도하세요.')),
                  );
                }
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:floorplans/screens/admin/select_map.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController uname = TextEditingController();
  TextEditingController upaswd = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang đăng nhập'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Login Image
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                  width: 230,
                  height: 200,
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            //Edit Text
            SizedBox(height: 20.0),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: uname,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tên đăng nhập',
                    hintText: 'Vui lòng điền tên đăng nhập'),
              ),
            ),

            SizedBox(height: 10.0),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: upaswd,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mật khẩu',
                    hintText: 'Vui lòng nhập mật khẩu'),
              ),
            ),

            SizedBox(height: 20.0),

            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0)),
              child: ElevatedButton(
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  String _name = uname.text.toString().trim();
                  String _paswd = upaswd.text.toString();

                  if (_name.isEmpty) {
                    print('Vui lòng không để trống tên đăng nhập');
                  } else if (_paswd.isEmpty) {
                    print('Vui lòng nhập mật khẩu');
                  } else {
                    final users = FirebaseFirestore.instance
                        .collection('users')
                        .doc('admin');

                    await users.get().then((DocumentSnapshot documentSnapshot) {
                      if (documentSnapshot.exists) {
                        if (_name ==
                                documentSnapshot.get(FieldPath(['username'])) &&
                            _paswd ==
                                documentSnapshot.get(FieldPath(['password']))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đăng nhập thành công')));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SelectMapScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đăng nhập thất bại')));
                        }
                      } else {
                        print("Chưa có tài khoản admin");
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

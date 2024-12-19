import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopshoes/pages/home.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:shopshoes/pages/signup.dart';
import 'package:shopshoes/pages/bottomnav.dart';
import 'package:shopshoes/services/shared_pref.dart';
import 'package:shopshoes/services/database.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      var userSnapshot = await DatabaseMethods().getUserByUserEmail(email);
      var userName = userSnapshot.docs.first.get('name');

      var imageSnapshot = await DatabaseMethods().getUserImageByEmail(email);
      var userImage = imageSnapshot.docs.first.get('imgUrl');

      await SharedPreferenceHelper().saveUserEmail(email);
      await SharedPreferenceHelper().saveUserName(userName);
      await SharedPreferenceHelper().saveUserImage(userImage);

      await SharedPreferenceHelper().saveUserLoggedIn(true);


      Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomNav()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Khong ton tai user!",
              style: TextStyle(fontSize: 20),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Sai mat khau!",
              style: TextStyle(fontSize: 20),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
          child: Form(
            key: _formkey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/login.png"),
                      Center(
                        child: Text("DANG NHAP",
                            style: AppWidget.semiboldTextFieldStyle()),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Vui long dien day du thong tin duoi day de tiep tuc",
                        style: AppWidget.lightTextFieldStyle(),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Email",
                        style: AppWidget.semiboldTextFieldStyle(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F9),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui long nhap dung email';
                            }
                            final bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value);
                            if (!emailValid) {
                              return "Vui long nhap lai dinh dang email";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Email"),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Mat Khau",
                        style: AppWidget.semiboldTextFieldStyle(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F9),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui long nhap dung mat khau';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Mat khau"),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Quen mat khau",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = emailController.text;
                              password = passwordController.text;
                            });
                            userLogin();
                          }
                        },
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Đăng Nhập",
                                style: TextStyle(
                                    color: Color(0xFFF4F5F9),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Không có tài khoản?",
                            style: AppWidget.lightTextFieldStyle(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUp()));
                              },
                              child: const Text(
                                "Đăng ký",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      )
                    ],
                  )
                ],
              ),),
        )
      ),
    );
  }
}

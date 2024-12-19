import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopshoes/pages/bottomnav.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:shopshoes/pages/login.dart';
import 'package:random_string/random_string.dart';
import 'package:shopshoes/services/database.dart';
import 'package:shopshoes/services/shared_pref.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? name, email, password;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Dang ky thanh cong!",
          style: TextStyle(fontSize: 20),
        ),
      ));

      String id = randomAlphaNumeric(10);

      await SharedPreferenceHelper().saveUserEmail(emailController.text);
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserName(nameController.text);
      await SharedPreferenceHelper().saveUserImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png");

      Map<String, dynamic> userInfoMap = {
        "name": nameController.text,
        "email": emailController.text,
        "id": id,
        "imgUrl": "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
      };

      await DatabaseMethods().addUserDetails(userInfoMap, id);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const BottomNav()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Password qua ngan!",
              style: TextStyle(fontSize: 20),
            )));
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Email da duoc su dung!",
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
            key: _formKey,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("images/login.png"),
                    Center(
                      child: Text("ĐĂNG KÝ",
                          style: AppWidget.semiboldTextFieldStyle()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Vui lòng điền đầy đủ thông tin dưới đây để tiếp tục",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Họ và Tên",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui long nhap dung ten';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Họ tên"),
                      ),
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
                        controller: emailController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Email"),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Mật Khẩu",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui long nhap dung password';
                          }
                          return null;
                        },
                        controller: passwordController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Mật Khẩu"),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            name = nameController.text;
                            email = emailController.text;
                            password = passwordController.text;
                          });
                          registration();
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
                              "Đăng Ký",
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
                          "Đã có tài khoản?",
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
                                    builder: (context) => const Login()));
                          },
                          child: const Text(
                            "Đăng Nhập",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

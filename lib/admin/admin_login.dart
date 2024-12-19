import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/admin/home_admin.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/login.png"),
                      Center(
                        child: Text("ADMIN PANEL",
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
                        "Username",
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
                          controller: usernameController,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Username"),
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
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          loginAdmin();
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
                                "Login",
                                style: TextStyle(
                                    color: Color(0xFFF4F5F9),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
          )
      ),
    );
  }

  loginAdmin() {
    FirebaseFirestore.instance.collection("Admin").get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        if (result.data()["username"] == usernameController.text.trim()) {
          if (result.data()["password"] == passwordController.text.trim()) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Sai mat khau"),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sai username"),
          ));
        }
      }
    });
  }
}

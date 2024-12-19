import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopshoes/services/database.dart';
import 'package:shopshoes/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopshoes/pages/login.dart';
import 'package:shopshoes/admin/add_product.dart';
import 'package:shopshoes/admin/all_orders.dart';
import 'package:shopshoes/admin/all_products.dart';
import 'package:shopshoes/admin/home_admin.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name, image, email;
  bool isAdmin = false;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        getTheSharePref();
      }
    });
  }

  Future<void> getTheSharePref() async {
    name = await SharedPreferenceHelper().getUserName();
    image = await SharedPreferenceHelper().getUserImage();
    email = await SharedPreferenceHelper().getUserEmail();

    if (email != null) {
      isAdmin = await DatabaseMethods().getAdminByRole(email!);
    }

    setState(() {});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await SharedPreferenceHelper().saveUserLoggedIn(false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
      );
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      } else {
        print("No image selected");
      }
    });
  }

  Future<void> upLoadItem() async {
    if (selectedImage != null) {
      String addId = randomString(10);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("productImages")
          .child(addId);
      UploadTask uploadTask = ref.putFile(selectedImage!);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();

      await SharedPreferenceHelper().saveUserImage(downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,  // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Hồ sơ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xfff2f2f2),
          elevation: 0,
        ),
        backgroundColor: const Color(0xfff2f2f2),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: getImage,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: image != null
                          ? NetworkImage(image!)
                          : const AssetImage('images/profile_image.png') as ImageProvider,
                      child: selectedImage != null
                          ? ClipOval(
                        child: Image.file(
                          selectedImage!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name ?? "No name provided",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email ?? "No email provided",
                    style: AppWidget.semiboldTextFieldStyle(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: upLoadItem,
                    child: const Text("Cập nhật ảnh đại diện mới"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: const Text("Đăng xuất"),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
                      },
                      child: const Text("Menu Admin"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

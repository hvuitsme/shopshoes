import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopshoes/services/database.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String? value;
  final List<String> _category = [
    "Adidas",
    "Nike",
    "Converse",
    "Vans"
  ];

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      } else {
        print("No image selected");
      }
    });
  }

  upLoadItem() async {
    if (selectedImage != null && productNameController.text.isNotEmpty &&
        value != null && productPriceController.text.isNotEmpty) {
      String addId = randomString(10);
      Reference ref = FirebaseStorage.instance.ref()
          .child("productImages")
          .child(addId);
      UploadTask uploadTask = ref.putFile(selectedImage!);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();

      String firstLetter = productNameController.text.substring(0, 1).toUpperCase();

      Map<String, dynamic> productMap = {
        "image": downloadUrl,
        "name": productNameController.text,
        "price": productPriceController.text,
        "updateName" : productNameController.text.toUpperCase(),
        "searchKey" : firstLetter,
        "description": productDescriptionController.text,
        "category": value
      };

      await DatabaseMethods().addProduct(productMap, value!).then((value) async {
        await DatabaseMethods().addProducts(productMap);
        selectedImage = null;
        productNameController.text = "";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("San pham da duoc them thanh cong", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Lobster",
              letterSpacing: 1.5,
              wordSpacing: 2,
              height: 1.5,
              shadows: const [
                Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: Offset(1, 1)
                )
              ],
              decoration: TextDecoration.underline,
              decorationColor: Colors.red,
              decorationStyle: TextDecorationStyle.dotted,
              decorationThickness: 2,
              background: Paint()..color = Colors.blue,
              foreground: Paint()..color = Colors.red,
          ),),
        ));
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Add Product", style: AppWidget.semiboldTextFieldStyle(),),
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tai len anh san pham", style: AppWidget.lightTextFieldStyle(),),
                const SizedBox(height: 20,),
                Center(
                  child: GestureDetector(
                    onTap: (){
                      getImage();
                    },
                    child: selectedImage != null ? Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F9),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Image.file(selectedImage!, fit: BoxFit.cover,),
                    ) : Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F9),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.black,),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text("Ten san pham", style: AppWidget.lightTextFieldStyle(),),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F9),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextField(
                    controller: productNameController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ten san pham"
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text("Gia san pham", style: AppWidget.lightTextFieldStyle(),),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F9),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextField(
                    controller: productPriceController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Gia san pham"
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text("The loai", style: AppWidget.lightTextFieldStyle(),),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F9),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      items: _category.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          this.value = value;
                        });
                      },
                      hint: const Text("Chon the loai"),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black,),
                      value: value,
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text("Mo ta san pham", style: AppWidget.lightTextFieldStyle(),),
                const SizedBox(height: 20,),
                //toi muon muc mo ta san pham nay la textfield to
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F9),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextField(
                    controller: productDescriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Mo ta san pham"
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Center(
                  child: ElevatedButton(onPressed: (){
                    upLoadItem();
                  }, style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ), child: Text("Them san pham"),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}

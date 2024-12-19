import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopshoes/services/database.dart';

class UpdateProduct extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const UpdateProduct({super.key, required this.productId, required this.productData});

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
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
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.productData['name'] ?? '';
    productPriceController.text = widget.productData['price'] ?? '';
    productDescriptionController.text = widget.productData['description'] ?? '';
    value = widget.productData['category'];
    imageUrl = widget.productData['image'];
  }

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

  updateItem() async {
    if (productNameController.text.isNotEmpty &&
        value != null && productPriceController.text.isNotEmpty) {

      String firstLetter = productNameController.text.substring(0, 1).toUpperCase();
      String? downloadUrl;

      if (selectedImage != null) {
        Reference ref = FirebaseStorage.instance.ref()
            .child("productImages")
            .child(widget.productId);
        UploadTask uploadTask = ref.putFile(selectedImage!);
        downloadUrl = await (await uploadTask).ref.getDownloadURL();
      }

      Map<String, dynamic> productMap = {
        "image": downloadUrl ?? imageUrl,
        "name": productNameController.text,
        "price": productPriceController.text,
        "updateName": productNameController.text.toUpperCase(),
        "searchKey": firstLetter,
        "description": productDescriptionController.text,
        "category": value
      };

      await DatabaseMethods().updateProduct(widget.productId, productMap).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Sản phẩm đã được cập nhật thành công"),
        ));
        Navigator.pop(context);
      });
    }
  }

  deleteItem() async {
    await DatabaseMethods().deleteProduct(widget.productId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sản phẩm đã được xóa"),
      ));
      Navigator.pop(context);
    });
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
        title: Text("Update Product", style: AppWidget.semiboldTextFieldStyle(),),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red,),
            onPressed: deleteItem,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tải lên ảnh sản phẩm", style: AppWidget.lightTextFieldStyle(),),
              const SizedBox(height: 20,),
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: selectedImage != null
                      ? Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F9),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.file(selectedImage!, fit: BoxFit.cover,),
                  )
                      : imageUrl != null
                      ? Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F9),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.network(imageUrl!, fit: BoxFit.cover,),
                  )
                      : Container(
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
              Text("Tên sản phẩm", style: AppWidget.lightTextFieldStyle(),),
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
                      hintText: "Tên sản phẩm"
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text("Giá sản phẩm", style: AppWidget.lightTextFieldStyle(),),
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
                      hintText: "Giá sản phẩm"
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text("Thể loại", style: AppWidget.lightTextFieldStyle(),),
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
                    hint: const Text("Chọn thể loại"),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black,),
                    value: value,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text("Mô tả sản phẩm", style: AppWidget.lightTextFieldStyle(),),
              const SizedBox(height: 20,),
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
                      hintText: "Mô tả sản phẩm"
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Center(
                child: ElevatedButton(
                  onPressed: updateItem,
                  style: ElevatedButton.styleFrom(
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
                  ),
                  child: Text("Cập nhật sản phẩm"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

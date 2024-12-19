import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:shopshoes/services/database.dart';
import 'package:shopshoes/pages/product_detail.dart';
import 'package:intl/intl.dart';

class CategoryProducts extends StatefulWidget {
  final String category;
  const CategoryProducts({super.key, required this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  Stream<QuerySnapshot>? CategoryProductsStream;
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  getProducts() async {
    CategoryProductsStream = await DatabaseMethods().getProduct(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream: CategoryProductsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Image.network(
                    ds["image"],
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("images/placeholder_image.png",
                          height: 150, width: 150, fit: BoxFit.cover);
                    },
                  ),
                  Text(ds["name"], style: AppWidget.semiboldTextFieldStyle()),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(double.parse(ds["price"])),
                        style: const TextStyle(
                          color: Color(0xFFFD6F3E),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                name: ds["name"],
                                price: ds["price"],
                                description: ds["description"],
                                image: ds["image"],
                                category: ds["category"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFD6F3E),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          itemCount: snapshot.data!.docs.length,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        elevation: 0,
        title: Text(widget.category,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20, left: 20, right: 10, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: allProducts()),
          ],
        ),
      ),
    );
  }
}

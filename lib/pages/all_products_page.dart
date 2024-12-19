import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:shopshoes/pages/product_detail.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  Stream<QuerySnapshot>? allProductsStream;

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  void getAllProducts() {
    allProductsStream = FirebaseFirestore.instance.collection("products").snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: const Text('Tất cả sản phẩm', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: allProductsStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No products available"));
            }

            var products = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = products[index];
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
                      ),
                      Text(
                        ds["name"],
                        style: AppWidget.semiboldTextFieldStyle(),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            ds["price"],
                            style: const TextStyle(
                              color: Color(0xFFFD6F3E),
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 35),
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
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

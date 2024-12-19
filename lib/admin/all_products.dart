import 'package:flutter/material.dart';
import 'package:shopshoes/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/admin/update_product.dart';

class AllProductsAdmin extends StatefulWidget {
  const AllProductsAdmin({super.key});

  @override
  State<AllProductsAdmin> createState() => _AllProductsAdminState();
}

class _AllProductsAdminState extends State<AllProductsAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận"),
          content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                DatabaseMethods().deleteProduct(productId);
                Navigator.pop(context);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách sản phẩm"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var productData = product.data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(productData['image']),
                title: Text(productData['name']),
                subtitle: Text("Giá: ${productData['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteProduct(product.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProduct(
                        productId: product.id,
                        productData: productData,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

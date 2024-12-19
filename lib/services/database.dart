import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future addProduct(Map<String, dynamic> productMap, String categoryName) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .add(productMap);
  }

  Future addProducts(Map<String, dynamic> productMap) async {
    return await FirebaseFirestore.instance
        .collection("products")
        .add(productMap);
  }

  Future getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get();
  }

  Future getUserImageByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

  Future getUserNameByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

  Future<Stream<QuerySnapshot>> getProduct(String category) async {
    return FirebaseFirestore.instance
        .collection(category)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getAllOrders() async {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("Status", isEqualTo: "Đã Thanh Toán")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getOrders(String email) async {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

  Future orderDetails(Map<String, dynamic> orderMap) async {
    return await FirebaseFirestore.instance
        .collection("orders")
        .add(orderMap);
  }

  Future updateOrderStatus(String id) async {
    return await FirebaseFirestore.instance
        .collection("orders")
        .doc(id)
        .update({"Status": "Đã Giao Hàng"});
  }

  Future<QuerySnapshot> search(String searchField) {
    return FirebaseFirestore.instance
        .collection("products")
        .where('searchKey',
        isEqualTo: searchField.substring(0, 1).toUpperCase())
        .get();
  }

  Future<bool> getAdminByRole(String email) async {
    bool isAdmin = false;
    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      for (var result in value.docs) {
        if (result.data()["role"] == "admin") {
          isAdmin = true;
        }
      }
    });
    return isAdmin;
  }

  Stream<QuerySnapshot> getAllProducts() {
    return FirebaseFirestore.instance.collection("products").snapshots();
  }

  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection("products").doc(id).delete();
  }

  Future getProductById(String id) async {
    return await FirebaseFirestore.instance
        .collection("products")
        .doc(id)
        .get();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updatedProduct) async {
    await FirebaseFirestore.instance
        .collection("products")
        .doc(id)
        .update(updatedProduct);
  }

  Future<QuerySnapshot> getRevenueData() async {
    return await FirebaseFirestore.instance.collection("orders").get();
  }

  Future addCart(Map<String, dynamic> cartMap) async {
    return await FirebaseFirestore.instance
        .collection("cart")
        .add(cartMap);
  }


  Future<void> deleteCart(String id) async {
    await FirebaseFirestore.instance.collection("cart").doc(id).delete();
  }

  Future<Stream<QuerySnapshot>> getCart(String email) async {
    return FirebaseFirestore.instance
        .collection("cart")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

}


import 'package:flutter/material.dart';
import 'package:shopshoes/services/database.dart';
import 'package:shopshoes/services/shared_pref.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/pages/product_detail.dart';
import 'package:shopshoes/services/constrant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';  // Import intl package

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  Stream<QuerySnapshot>? cartStream;
  double totalAmount = 0.0;
  Map<String, dynamic>? paymentIntent;

  // Create a NumberFormat instance for Vietnamese Dong
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() async {
    try {
      String? email = await SharedPreferenceHelper().getUserEmail();
      if (email != null) {
        // Await the Future to get the Stream
        Stream<QuerySnapshot> cartStreamTemp = await DatabaseMethods().getCart(email);
        setState(() {
          cartStream = cartStreamTemp;
        });

        // Listen to the Stream for updates
        cartStream!.listen((snapshot) {
          double total = 0.0;
          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            double price = double.tryParse(data['Price'] ?? '0') ?? 0;
            int quantity = data['Quantity'] ?? 1;
            total += price * quantity;
          }
          setState(() {
            totalAmount = total;
          });
        });
      } else {
        print("Email not found");
      }
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: 'Shop Shoes'))
          .then((_) {});
      displayPaymentSheet();
    } catch (e, s) {
      print('Exception: $e$s');
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        // Process orders and clear cart
        await processOrders();
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Thanh Toan Thanh Cong',
                        style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        );
        setState(() {
          totalAmount = 0.0; // Reset total amount
        });
      });
    } on StripeException catch (e, s) {
      print('StripeException: $e$s');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Thanh Toan That Bai',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e, s) {
      print('Exception: $e$s');
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );
      return jsonDecode(response.body);
    } catch (e, s) {
      print('Exception: $e$s');
      return null;
    }
  }

  String calculateAmount(String amount) {
    return (double.parse(amount) * 100).toStringAsFixed(0);
  }

  Future<void> processOrders() async {
    try {
      String? email = await SharedPreferenceHelper().getUserEmail();
      if (email != null) {
        var cartSnapshot = await FirebaseFirestore.instance
            .collection('carts')
            .doc(email)
            .collection('items')
            .get();

        for (var doc in cartSnapshot.docs) {
          var cartItem = doc.data();
          Map<String, dynamic> orderInfoMap = {
            'Product': cartItem['Product'],
            'Price': cartItem['Price'],
            'ProductImage': cartItem['ProductImage'],
            'Email': email,
            'Name': await SharedPreferenceHelper().getUserName(),
            'Status': 'Đã Thanh Toán',
            'Date': DateTime.now().millisecondsSinceEpoch * 1000,
          };
          await DatabaseMethods().orderDetails(orderInfoMap);
        }

        await FirebaseFirestore.instance.collection('carts').doc(email).collection('items').get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      }
    } catch (e) {
      print('Error processing orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng của bạn"),
        backgroundColor: const Color(0xfff2f2f2),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Giỏ hàng đang trống"));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var cartItem = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                  name: cartItem['Product'],
                                  price: cartItem['Price'],
                                  description: cartItem['description'],
                                  image: cartItem['ProductImage'],
                                  category: cartItem['category']
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Image.network(cartItem['ProductImage'], width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(cartItem['Product'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Giá tiền: ${currencyFormat.format(double.tryParse(cartItem['Price'] ?? '0') ?? 0)}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await DatabaseMethods().deleteCart(snapshot.data!.docs[index].id);
                                } catch (e) {
                                  print("Error deleting cart item: $e");
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tổng tiền: ${currencyFormat.format(totalAmount)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (totalAmount > 0) {
                            makePayment(totalAmount.toStringAsFixed(2));
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => const AlertDialog(
                                content: Text('Giỏ hàng trống!'),
                              ),
                            );
                          }
                        },
                        child: const Text("Tiến hành thanh toán"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shopshoes/services/constrant.dart';
import 'dart:convert';
import 'package:shopshoes/services/shared_pref.dart';
import 'package:shopshoes/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductDetail extends StatefulWidget {
  final String name, price, description, image, category;

  const ProductDetail({super.key, 
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String? name, email, image;
  TextEditingController commentController = TextEditingController();
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  onTheLoad() async {
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef5f1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(widget.image,
                    height: 400, width: 400, fit: BoxFit.cover),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.name,
                            style: AppWidget.boldTextFieldStyle()),
                        Text(
                          currencyFormat.format(double.parse(widget.price)),
                          style: const TextStyle(
                              color: Color(0xFFfd6f3e),
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        Map<String, dynamic> cartMap = {
                          'Product': widget.name,
                          'Price': widget.price,
                          'ProductImage': widget.image,
                          'Email': email,
                          'Name': name,
                          'category': widget.category,
                          'description' : widget.description,
                          'Quantity': 1,
                        };
                        await DatabaseMethods().addCart(cartMap);

                        showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Sản phẩm đã được thêm vào giỏ hàng', style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Thêm vào giỏ hàng",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Nội dung",
                        style: AppWidget.semiboldTextFieldStyle()),
                    const SizedBox(height: 10),
                    Text(widget.description,
                        style: AppWidget.lightTextFieldStyle(),
                        textAlign: TextAlign.justify),
                    const SizedBox(height: 70),
                    GestureDetector(
                      onTap: () {
                        makePayment(widget.price);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: const Color(0xFFfd6f3e),
                            borderRadius: BorderRadius.circular(10)),
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: Text("Mua Ngay",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Bình luận",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Viết bình luận của bạn...",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: addComment,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.name)
                          .collection('comments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var comment = snapshot.data!.docs[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  comment['userImage'] ?? '',
                                ),
                              ),
                              title: Text(comment['username'] ?? ''),
                              subtitle: Text(comment['comment'] ?? ''),
                              trailing: Text(
                                DateFormat('dd MMM yyyy, HH:mm')
                                    .format(comment['timestamp'].toDate()),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
        Map<String, dynamic> orderInfoMap = {
          'Product': widget.name,
          'Price': widget.price,
          'ProductImage': widget.image,
          'Email': email,
          'Name': name,
          'Image': image,
          'Status': 'Đã Thanh Toán',
          'Date': DateTime.now().millisecondsSinceEpoch * 1000,
        };
        await DatabaseMethods().orderDetails(orderInfoMap);

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
        paymentIntent = null;
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

  void addComment() async {
    if (commentController.text.isNotEmpty) {
      Map<String, dynamic> commentMap = {
        'username': name,
        'userImage': image,
        'comment': commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.name)
          .collection('comments')
          .add(commentMap);

      commentController.clear();
    }
  }
}

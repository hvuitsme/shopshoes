import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/services/database.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream? orderStream;

  Future<void> getOnTheLoad() async {
    orderStream = await DatabaseMethods().getAllOrders();
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }

  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.isEmpty) {
          return const Center(
              child: Text("No orders found.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
        }

        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(
                  vertical: 8), // Adjusted vertical margin
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16), // Reduced padding
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      ds["ProductImage"],
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16), // Spacing between image and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tên: " + ds["Name"],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Email: " + ds["Email"],
                              style: AppWidget.lightTextFieldStyle()),
                          const SizedBox(height: 8),
                          Text(ds["Product"],
                              style: AppWidget.semiboldTextFieldStyle()),
                          const SizedBox(height: 4),
                          Text(
                            "Giá tiền: " + ds["Price"],
                            style: const TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              await DatabaseMethods().updateOrderStatus(ds.id);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8), // Adjusted vertical padding
                              decoration: BoxDecoration(
                                color: const Color(0xFFfd6f3e),
                                borderRadius:
                                    BorderRadius.circular(8), // Adjusted radius
                              ),
                              child: Center(
                                child: Text(
                                  "Hoàn thành",
                                  style: AppWidget.semiboldTextFieldStyle()
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tất cả đơn hàng", style: AppWidget.boldTextFieldStyle()),
        backgroundColor: const Color(0xfff2f2f2),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: allOrders(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopshoes/widget/support_widget.dart';
import 'package:shopshoes/pages/category_products.dart';
import 'package:shopshoes/services/shared_pref.dart';
import 'package:shopshoes/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopshoes/pages/product_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopshoes/pages/all_products_page.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  List<dynamic> allProducts = [];

  List<String> categories = [
    "images/adidas.png",
    "images/nike.png",
    "images/Converse.png",
    "images/vans.png"
  ];

  List<String> categoryName = ["Adidas", "Nike", "Converse", "Vans"];

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  var queryResultSet = [];
  var tempSearchStore = [];

  void getAllProducts() async {
    DatabaseMethods().getAllProducts().listen((QuerySnapshot snapshot) {
      setState(() {
        allProducts = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    });
  }

  void initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
      return;
    }

    setState(() {
      search = true;
    });

    var capitalizedValue = value.substring(0,1).toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1){
      DatabaseMethods().search(value).then((QuerySnapshot docs){
        for (int i = 0; i < docs.docs.length; ++i){
          queryResultSet.add(docs.docs[i].data());
        }
      });
      } else {
        tempSearchStore = [];
        for (var element in queryResultSet) {
          if (element["updateName"].startsWith(capitalizedValue)){
            setState(() {
              tempSearchStore.add(element);
            });
          }
        }
    }
  }


  String? name, image;

  bool isLoading = true;

  onTheLoad() async {
    name = await SharedPreferenceHelper().getUserName();
    image = await SharedPreferenceHelper().getUserImage();
    print("Name: $name, Image: $image");

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey, $name",
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                      Text(
                        "Chào mừng bạn",
                        style: AppWidget.lightTextFieldStyle(),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      image ??
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                            "assets/images/placeholder_image.png",
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  onChanged: (value) {
                    initiateSearch(value.toUpperCase());
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tìm kiếm sản phẩm",
                      hintStyle: AppWidget.lightTextFieldStyle(),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              search ? ListView(
                padding: const EdgeInsets.only(left: 10, right: 10),
                primary: false,
                shrinkWrap: true,
                children: tempSearchStore.map((element) {
                  return buildResultCard(element);
                }).toList(),
              )
                  : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Danh mục",
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllProductsPage()));
                          }
                          ,child: const Text(
                            "Tất cả",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFD6F3E),
                              borderRadius: BorderRadius.circular(10)),
                          height: 130,
                          child: const Center(
                            child: Text("All",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                          )),
                      Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            height: 130,
                            child: ListView.builder(
                              itemCount: categories.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return CategoryTile(
                                    image: categories[index],
                                    name: categoryName[index]);
                              },
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  search
                      ? ListView(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    shrinkWrap: true,
                    primary: false,
                    children: tempSearchStore.map((element) {
                      return buildResultCard(element);
                    }).toList(),
                  )
                      :
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tất cả sản phẩm",
                           style: AppWidget.semiboldTextFieldStyle(),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllProductsPage()));
                              }
                              ,child: const Text(
                              "Tất cả",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: DatabaseMethods().getAllProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: Text("No products found"));
                          }

                          var products = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

                          return SizedBox(
                            height: 240,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: products.map((product) {
                                return buildProductTile(product);
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
  ],
        ),
      ),
      ),
    );
  }

  Widget buildResultCard(data) {
    // Assuming 'price' is a number or can be converted to double
    final double price = double.tryParse(data["price"]?.replaceAll(',', '') ?? '0') ?? 0;
    final formattedPrice = currencyFormat.format(price);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(
                    name: data["name"],
                    price: data["price"],
                    description: data["description"],
                    image: data["image"],
                    category: data["category"])));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data["image"],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("images/placeholder_image.png",
                      height: 70, width: 70, fit: BoxFit.cover);
                },
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"],
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  formattedPrice,  // Use formatted price here
                  style: const TextStyle(
                      color: Color(0xFFFD6F3E),
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget buildProductTile(product) {
    // Assuming 'price' is a number or can be converted to double
    final double price = double.tryParse(product["price"]?.replaceAll(',', '') ?? '0') ?? 0;
    final formattedPrice = currencyFormat.format(price);

    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Image.network(
            product["image"] ?? "images/shoesback.png",
            height: 150,
            width: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset("images/placeholder_image.png",
                  height: 150, width: 150, fit: BoxFit.cover);
            },
          ),
          Text(product["name"] ?? "Giày vip", style: AppWidget.semiboldTextFieldStyle()),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                formattedPrice,  // Use formatted price here
                style: const TextStyle(
                    color: Color(0xFFFD6F3E),
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 50),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetail(
                              name: product["name"],
                              price: product["price"],
                              description: product["description"],
                              image: product["image"],
                              category: product["category"])));
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFD6F3E),
                      borderRadius: BorderRadius.circular(5)),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}

class CategoryTile extends StatelessWidget {
  final String image, name;
  const CategoryTile({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoryProducts(category: name)));
        },
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          height: 90,
          width: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                image,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 10,
              ),
              const Icon(Icons.arrow_forward)
            ],
          ),
        ));
  }
}

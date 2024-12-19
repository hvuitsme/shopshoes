import 'package:flutter/material.dart';
import 'package:shopshoes/pages/home.dart';
import 'package:shopshoes/pages/Order.dart';
import 'package:shopshoes/pages/Profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shopshoes/pages/cart.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;
  late Home HomePage;
  late Order order;
  late Profile profile;
  late Cart cart;
  int currentTabIndex = 0;

  @override
  void initState() {
    HomePage = const Home();
    order = const Order();
    profile = const Profile();
    cart = Cart();
    pages = [HomePage, order, cart, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
          backgroundColor: const Color(0xfff2f2f2),
          color: Colors.black,
          animationDuration: const Duration(microseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex=index;
            });
          },
          items: const [
        Icon(
          Icons.home_outlined,
          color: Colors.white,
        ),
        Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
        ),
        Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
        ),
        Icon(
          Icons.person_outlined,
          color: Colors.white,
        )
      ]),
      body: pages[currentTabIndex],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/explore_screen/explore_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/favourites/favourite_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/WishlistController.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/sub_home_screen/sub_home_screen.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'sub_screens/account/account.dart';

class RootHomeScreen extends StatefulWidget {
  const RootHomeScreen({Key? key}) : super(key: key);

  @override
  State<RootHomeScreen> createState() => _RootHomeScreenState();
}

class _RootHomeScreenState extends State<RootHomeScreen> {
  final homeController = Get.put(HomeController());
  final cartController = Get.put(CartController());
  final wishlistController = Get.put(WishlistController());

  final List<Map<String, dynamic>> _bottomNavbarData = [
    {
      "iconOutlined": Icons.home_outlined,
      "iconFilled": Icons.home,
      "label": "Home"
    },
    {
      "iconOutlined": Icons.category_outlined,
      "iconFilled": Icons.category,
      "label": "Category"
    },
    // {
    //   "iconOutlined": Icons.shopping_cart_outlined,
    //   "iconFilled": Icons.shopping_cart,
    //   "label": "My Cart"
    // },
    {
      "iconOutlined": Icons.favorite_outline,
      "iconFilled": Icons.favorite,
      "label": "Favourite"
    },
    {
      "iconOutlined": Icons.account_circle_outlined,
      "iconFilled": Icons.account_circle,
      "label": "My Account"
    },
  ];

  final List<Widget> listOfScreens = [
    OptimizedSubHomeScreen(),
    ExploreScreen(),
    // Cart(),
    FavouriteScreen(),
    Account(),
  ];

  @override
  void initState() {
    super.initState();
    _preloadData();
  }

  Future<void> _preloadData() async {
    final userId = await SharedPref.getUserId();
    if (userId != null && userId.isNotEmpty) {
      // ✅ Preload both wishlist & cart counts
      await wishlistController.getWishlist(userId);
      await cartController.getCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Obx(() => listOfScreens[homeController.currentIndex.value]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth / 13.57),
          height: screenWidth / 4.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth / 20.7),
              topRight: Radius.circular(screenWidth / 20.7),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -4),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.25),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_bottomNavbarData.length, (index) {
              return Obx(() {
                final isSelected = homeController.currentIndex.value == index;
                final IconData icon = isSelected
                    ? _bottomNavbarData[index]['iconFilled']
                    : _bottomNavbarData[index]['iconOutlined'];

                return Obx(() {
                  final isSelected = homeController.currentIndex.value == index;
                  final IconData icon = isSelected
                      ? _bottomNavbarData[index]['iconFilled']
                      : _bottomNavbarData[index]['iconOutlined'];

                  return InkWell(
                    onTap: () => homeController.currentIndex.value = index,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              icon,
                              size: screenWidth / 13.25,
                              color: isSelected ? primaryColor : Colors.black54,
                            ),
                            // if ((index == 2 &&
                            //         cartController.isCartCount.value > 0) ||
                            //     (index == 3 &&
                            //         wishlistController.wishlistCount.value > 0))

                            if (index == 2 &&
                                wishlistController.wishlistCount.value > 0)
                              Positioned(
                                top: -6,
                                right: -3,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor:
                                      isSelected ? primaryColor : Colors.grey,
                                  child: Text(
                                    wishlistController.wishlistCount.value
                                        .toString(),
                                    // index == 3
                                    //     ? wishlistController.wishlistCount.value
                                    //         .toString()
                                    //     : cartController.isCartCount.value
                                    //         .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bottomNavbarData[index]['label'],
                          style: TextStyle(
                            color: isSelected ? primaryColor : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth / 34.5,
                          ),
                        )
                      ],
                    ),
                  );
                });
              });
            }),
          ),
        ),
      ),
    );
  }
}

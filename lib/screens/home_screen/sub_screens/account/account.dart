import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/address_screens/address_screens.dart';
import 'package:organic_saga/screens/auth_screens/login_screens/login_screen.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/about_us.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/contact_us.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/my_detail/my_detail.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/orders/orders.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/privacy_policy.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/promocode/promocode.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/terms_condition.dart';
import 'package:organic_saga/screens/refer_earn_screen/refer_earn_screen.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/notifications/notification_controller.dart';

import '../../../../components/custom_divider.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final HomeController homeController = Get.put(HomeController());
  //final HomeController homeController = Get.find<HomeController>();
  final NotificationController notificationController =
      Get.put(NotificationController());

  void handleBackPress() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: "Profile",
        showBack: false,
        onBack: handleBackPress,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: () async {
              await SharedPref.clearAll();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Container(
              height: 50.h,
              color: const Color(0xFFF2F3F2),
              child: Center(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.h.verticalSpace,
            Obx(
              () => GestureDetector(
                onTap: () => Get.to(() => const MyDetail()),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            10.h.verticalSpace,
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    homeController.userModel.value.username ??
                                        "Fresh Basket",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                6.w.horizontalSpace,
                                Icon(
                                  Icons.edit,
                                  size: 18.sp,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                            Text(
                              "+91 ${homeController.userModel.value.mobile ?? "phone number"}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            20.h.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: primaryColor,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  child: Text(
                    "Wallet Bal: ₹ ${homeController.userModel.value.walletBalance ?? "0.00"}",
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
            20.h.verticalSpace,
            CustomDivider(screenWidth: 1.sw),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildItem("My Orders", Icons.shopping_bag_outlined,
                        const Orders()),
                    _buildItem("My Details", Icons.list_alt, MyDetail()),
                    _buildItem("My Address", Icons.location_on_outlined,
                        const AddressScreen()),
                    _buildItem("Promo Code", Icons.local_activity_outlined,
                        const PromoCode()),
                    _buildItem("Refer & Earn", Icons.savings_outlined,
                        ReferEarnScreen()),
                    // Obx(
                    //   () => _buildItem(
                    //     "Notifications",
                    //     Icons.notifications_none_outlined,
                    //     NotificationScreen(), // Just navigate, don’t clear here
                    //     trailing:
                    //         notificationController.notificationCount.value > 0
                    //             ? Container(
                    //                 width: 10.w,
                    //                 height: 10.w,
                    //                 decoration: const BoxDecoration(
                    //                   color: Colors.red,
                    //                   shape: BoxShape.circle,
                    //                 ),
                    //               )
                    //             : null,
                    //     onTap: () {
                    //       // Only navigate to the screen
                    //       Get.to(() => NotificationScreen());
                    //     },
                    //   ),
                    // ),
                    _buildItem("Contact Us", Icons.contact_support_outlined,
                        const ContactUs()),
                    _buildItem("Privacy Policy", Icons.security_outlined,
                        const PrivacyPolicyScreen()),
                    _buildItem("Terms & Conditions", Icons.newspaper_outlined,
                        const TermsCondition()),
                    _buildItem("About", Icons.info_outline, const AboutUs()),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, IconData icon, Widget screen,
      {Widget? trailing, VoidCallback? onTap}) {
    return IndividualProfileItemBuilder(
      iconData: icon,
      label: label,
      onPressed: onTap ??
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => screen)),
      trailing: trailing,
    );
  }
}

class IndividualProfileItemBuilder extends StatelessWidget {
  final String label;
  final IconData? iconData;
  final VoidCallback onPressed;
  final Widget? trailing;

  const IndividualProfileItemBuilder({
    Key? key,
    required this.label,
    required this.onPressed,
    this.iconData,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          16.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(iconData, color: Colors.black45, size: 22.sp),
                16.w.horizontalSpace,
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                if (trailing != null) trailing!,
                Icon(Icons.chevron_right_rounded,
                    color: Colors.black45, size: 22.sp),
              ],
            ),
          ),
          16.h.verticalSpace,
          Divider(
            thickness: 1,
            height: 1,
            indent: 30.w,
            color: const Color(0xFFE2E2E2),
          ),
        ],
      ),
    );
  }
}

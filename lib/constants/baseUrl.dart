/// BASE URL
const String baseUrl = "https://digiforgetech.com/celestialora/api/index.php";

/// IMAGE URLS
const String baseSliderImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/slider/";
const String baseProductImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/product/";
const String baseCategoryImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/category/";
const String baseProfileImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/profile/";
const String baseBannerImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/banner/";
const String baseNotificationImageUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/notification/";
const String baseInvoiceUrl =
    "https://digiforgetech.com/celestialora/admin/uploads/invoice/";

/// AUTH
const String loginApi = "$baseUrl/Auth/login_user";
const String verifyOtpApi = "$baseUrl/Auth/verify_otp";
const String resendOtpApi = "$baseUrl/Auth/resend_otp";
const String profileFetchApi = "$baseUrl/Auth/profile_fetch";
const String profileUpdateApi = "$baseUrl/Auth/profile_update";

/// HOME
const String sliderFetchApi = "$baseUrl/Auth/slider_fetch";
const String bestSellerProductApi = "$baseUrl/Auth/best_seller_product";
const String trendingProductApi = "$baseUrl/Auth/trending_product";

/// ADDRESS
const String addressSaveApi = "$baseUrl/Auth/address_save";
const String addressFetchApi = "$baseUrl/Auth/address_fetch";
const String addressUpdateApi = "$baseUrl/Auth/address_update";
const String addressDeleteApi = "$baseUrl/Auth/address_delete";

/// BLOG
const String blogCategoryFetchApi = "$baseUrl/Auth/blog_category_fetch";
const String blogListFetchApi = "$baseUrl/Auth/blog_list_fetch";
const String blogDetailsFetchApi = "$baseUrl/Auth/blog_details_fetch";

/// CATEGORY & PRODUCT
const String categoryListApi = "$baseUrl/Auth/category_list_fetch";
const String productListByCategoryApi = "$baseUrl/Auth/product_list_fetch";
const String productDetailsApi = "$baseUrl/Auth/product_details_fetch";

// ✅ Correct new API
const String productListByMultipleCategoryApi =
    "$baseUrl/Auth/product_list_bycatids_fetch";

/// CART
const String addToCartApi = "$baseUrl/Auth/add_to_cart";
const String getCartListApi = "$baseUrl/Auth/get_cart_list";
const String removeCartApi = "$baseUrl/Auth/remove_cart";
const String updateCartApi = "$baseUrl/Auth/update_cart";

/// WISHLIST
const String addWishlistApi = "$baseUrl/Auth/wishadd";
const String getWishlistApi = "$baseUrl/Auth/get_wishlist";
const String removeWishlistApi = "$baseUrl/Auth/remove_wishlist";

/// ORDER
const String myOrderListApi = "$baseUrl/Auth/my_order_list";
const String orderDetailsApi = "$baseUrl/Auth/order_details";

/// CHECKOUT
const String checkoutApi = "$baseUrl/Auth/checkout";
const String initiateGatewayApi = "$baseUrl/Auth/initiategateway";

/// FAQ & STATIC
const String faqListApi = "$baseUrl/Auth/faqs_list_fetch";
const String faqSaveApi = "$baseUrl/Auth/faqs_save";
const String aboutUsApi = "$baseUrl/Auth/about_fetch";
const String contactUsFetchApi = "$baseUrl/Auth/contactus_fetch";
const String contactUsSaveApi = "$baseUrl/Auth/contactus_save";
const String termsConditionApi = "$baseUrl/Auth/terms_condition";
const String privacyPolicyApi = "$baseUrl/Auth/privacy_policy_fetch";

/// NOTIFICATION & OTHERS
const String fcmTokenSaveApi = "$baseUrl/Auth/fcm";
const String notificationListApi = "$baseUrl/Auth/notificationlist";
const String notificationStatusChangeApi =
    "$baseUrl/Auth/notification_status_change";
const String notificationCountApi = "$baseUrl/Auth/notification_count";

const String searchApi = "$baseUrl/Auth/search";
const String cityListApi = "$baseUrl/Auth/city_list";
const String areaListApi = "$baseUrl/Auth/area_list";
const String couponCodeFetchApi = "$baseUrl/Auth/couponcode_fetch";
const String newsletterSaveApi = "$baseUrl/Auth/newsletter_save";

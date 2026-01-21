import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<Map<String, dynamic>> initiatePayment({
    required String addressId,
    required String couponCode,
    required String dataStore,
    required String userId,
    required String amount,
    required String walletAmount,
    required String couponAmount,
  }) async {
    final url = Uri.parse("https://digiforgetech.com/demo/api/index.php/Auth/initiategateway");

    var request = http.MultipartRequest("POST", url);
    request.fields.addAll({
      "address_id": addressId,
      "coupon_code": couponCode,
      "data_store": dataStore,
      "user_id": userId,
      "amount": amount,
      "wallet_amount": walletAmount,
      "coupon_amount": couponAmount,
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    } else {
      throw Exception("Failed to initiate payment: ${response.statusCode}");
    }
  }
}

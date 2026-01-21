import 'dart:convert';
import 'package:crypto/crypto.dart';

String getBody({
  required String merchantTransactionId,
  required String merchantUserId,
  required double amount,
  required String mobileNumber,
  bool useWallet = false,
  double walletBalance = 0.0,
  String targetApp = "com.phonepe.app",
}) {
  double finalAmount = amount;
  if (useWallet && walletBalance > 0) {
    finalAmount = amount - walletBalance;
    if (finalAmount < 0) finalAmount = 0;
  }

  var body = {
    "merchantId": "PGTESTPAYUAT",
    "merchantTransactionId": merchantTransactionId,
    "merchantUserId": merchantUserId,
    "amount": (finalAmount * 100).round(),
    "mobileNumber": mobileNumber,
    "callbackUrl": "https://your-backend.com/api/payment/callback",
    "paymentInstrument": {
      "type": "UPI_INTENT",
      "targetApp": targetApp,
    },
    "deviceContext": {"deviceOS": "ANDROID"}
  };

  return base64Encode(utf8.encode(jsonEncode(body)));
}

/// Generates the checksum required by PhonePe PG
String generateChecksum(String base64Body, String saltKey, String saltIndex) {
  const apiEndPoint = "/pg/v1/pay";
  final rawString = base64Body + apiEndPoint + saltKey;
  final sha256Hash = sha256.convert(utf8.encode(rawString)).toString();
  return "$sha256Hash###$saltIndex";
}

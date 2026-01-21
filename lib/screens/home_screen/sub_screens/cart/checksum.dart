import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates the checksum required by PhonePe PG
/// [base64Body] → request body (already encoded to Base64)
/// [saltKey] → Provided by PhonePe (TEST / PROD) (RAW STRING, not base64)
/// [saltIndex] → Provided by PhonePe (usually "1" for test env)
String generateChecksum(String base64Body, String saltKey, String saltIndex) {
  const apiEndPoint = "/pg/v1/pay";

  // PhonePe format: sha256(body + apiEndPoint + saltKey) + "###" + saltIndex
  final rawString = base64Body + apiEndPoint + saltKey;
  final sha256Hash = sha256.convert(utf8.encode(rawString)).toString();

  return "$sha256Hash###$saltIndex";
}

import 'dart:convert';
import 'package:otp/otp.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getCodes(int lastPostId) async {
  final String totp = _generateTheTOPD();
  final String formattedCode =
      _formatCode(totp: totp, other: lastPostId.toString());
  final Uri url = Uri.parse(
      'https://xclout-cdn.habertech.info/binancepacketcodes?lastCodeId=$formattedCode');

  final http.Response response = await http.get(url);
  final String body = response.body;
  return jsonDecode(body);
}

String _generateTheTOPD() {
  // Generate the TOTP code
  String secret = "HF4U2TBCN7LZ6QIE7AK6OFHI7LOWA4PG";
  // Secret
  final int timeEpoch =
      DateTime.now().toUtc().millisecondsSinceEpoch; // Use UTC timezone
  final String totp = OTP.generateTOTPCodeString(
    secret,
    timeEpoch,
    algorithm: Algorithm.SHA1, // HMAC-SHA1
    isGoogle: true, // Google Authenicator's ways
  );
  return totp;
}

String _formatCode({required String totp, required String other}) {
  // Split the topd code into 2 parts
  final int length = totp.length;
  final int halfLength = (length / 2).floor();

  final String part1 = totp.substring(0, halfLength); // First half
  final String part2 = totp.substring(halfLength, length); // Second half
  return part1 + other + part2;
}

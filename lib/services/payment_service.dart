import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/services/webview.dart';

class VNPayService {
  static const String vnpUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpTmnCode = 'OWPQI289';
  static const String vnpHashSecret = 'H2VS2ENXJBJIPTFN2UT1U7YCAOM8G0XE';
  static const String vnpReturnUrl = 'shipper-vnpay-return://vnpay-return';
  static const String vnpVersion = '2.1.0';
  static const String vnpCommand = 'pay';
  static const String vnpCurrCode = 'VND';
  static const String vnpOrderType = 'other';
  static const String vnpLocale = 'vn';

  static String getIpAddress(
    Map<String, String> headers,
    String remoteAddress,
  ) {
    String ip = headers['x-forwarded-for'] ?? remoteAddress;
    if (ip == '::1' || ip == '::ffff:127.0.0.1') ip = '127.0.0.1';
    return ip;
  }

  static String createPaymentUrl({
    required int amount,
    Map<String, String> headers = const {},
    String remoteAddress = '127.0.0.1',
  }) {
    final orderId = _getCurrentTimeFormatted('ddHHmmss');
    final createDay = _getCurrentTimeFormatted('yyyyMMddHHmmss');

    Map<String, String> vnpParams = {};
    vnpParams['vnp_Version'] = vnpVersion;
    vnpParams['vnp_Command'] = vnpCommand;
    vnpParams['vnp_TmnCode'] = vnpTmnCode;
    vnpParams['vnp_Locale'] = vnpLocale;
    vnpParams['vnp_CurrCode'] = vnpCurrCode;
    vnpParams['vnp_TxnRef'] = orderId;
    vnpParams['vnp_OrderInfo'] = 'Thanh toan cho ma GD: $orderId';
    vnpParams['vnp_OrderType'] = vnpOrderType;
    vnpParams['vnp_Amount'] = (amount * 100).toString();
    vnpParams['vnp_ReturnUrl'] = vnpReturnUrl;
    vnpParams['vnp_IpAddr'] = getIpAddress(headers, remoteAddress);
    vnpParams['vnp_CreateDate'] = createDay;

    vnpParams = _sortObject(vnpParams);

    String queryString = _buildQueryString(vnpParams, encode: false);
    final signed = _hmacSHA512(vnpHashSecret, queryString);
    vnpParams['vnp_SecureHash'] = signed;

    String paymentUrl =
        vnpUrl + '?' + _buildQueryString(vnpParams, encode: false);
    return paymentUrl;
  }

  static Future<void> processDeposit({
    required String userId,
    required BuildContext context,
    required double amount,
    required Function(bool success, String? responseCode, String message)
        onComplete,
  }) async {
    try {
      // Tạo URL thanh toán
      final paymentUrl = createPaymentUrl(
        amount: amount.toInt(),
        headers: {},
        remoteAddress: '127.0.0.1',
      );

      // Lưu thông tin giao dịch vào Firestore
      final transactionRef =
          FirebaseFirestore.instance.collection('transactions').doc();

      await transactionRef.set({
        'id': transactionRef.id,
        'amount': amount,
        'type': 'deposit',
        'status': 'pending',
        'paymentMethod': 'vnpay',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mở WebView để thanh toán
      if (context.mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VNPayWebViewScreen(
              paymentUrl: paymentUrl,
              userId: userId,
              onComplete: (success, responseCode) async {
                // Cập nhật trạng thái giao dịch
                await transactionRef.update({
                  'status': success ? 'completed' : 'failed',
                  'responseCode': responseCode,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                onComplete(
                  success,
                  responseCode,
                  success ? 'Nạp tiền thành công!' : 'Giao dịch thất bại',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      onComplete(false, null, 'Lỗi: $e');
    }
  }

  // static Future<void> _updateWalletBalance(
  //   String shipperId,
  //   double amount,
  // ) async {
  //   try {
  //     final walletRef =
  //         FirebaseFirestore.instance.collection('wallets').doc(shipperId);

  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       final walletDoc = await transaction.get(walletRef);

  //       if (walletDoc.exists) {
  //         final currentBalance = (walletDoc.data()?['balance'] ?? 0).toDouble();
  //         transaction.update(walletRef, {
  //           'balance': currentBalance + amount,
  //           'updatedAt': FieldValue.serverTimestamp(),
  //         });
  //       } else {
  //         transaction.set(walletRef, {
  //           'balance': amount,
  //           'shipperId': shipperId,
  //           'createdAt': FieldValue.serverTimestamp(),
  //           'updatedAt': FieldValue.serverTimestamp(),
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     print('Lỗi cập nhật số dư: $e');
  //   }
  // }

  static Map<String, String> _sortObject(Map<String, String> obj) {
    Map<String, String> sorted = {};
    List<String> str = [];

    for (String key in obj.keys) {
      if (obj.containsKey(key)) {
        str.add(Uri.encodeComponent(key));
      }
    }
    str.sort();

    for (int index = 0; index < str.length; index++) {
      String decodedKey = Uri.decodeComponent(str[index]);
      String value = Uri.encodeComponent(
        obj[decodedKey]!,
      ).replaceAll('%20', '+');
      sorted[str[index]] = value;
    }
    return sorted;
  }

  static String _buildQueryString(
    Map<String, String> params, {
    bool encode = true,
  }) {
    List<String> pairs = [];
    for (MapEntry<String, String> entry in params.entries) {
      String key = encode ? Uri.encodeComponent(entry.key) : entry.key;
      String value = encode ? Uri.encodeComponent(entry.value) : entry.value;
      pairs.add('$key=$value');
    }
    return pairs.join('&');
  }

  static String _getCurrentTimeFormatted(String format) {
    final now = DateTime.now().toUtc().add(Duration(hours: 7)); // GMT+7

    switch (format) {
      case 'ddHHmmss':
        return '${now.day.toString().padLeft(2, '0')}'
            '${now.hour.toString().padLeft(2, '0')}'
            '${now.minute.toString().padLeft(2, '0')}'
            '${now.second.toString().padLeft(2, '0')}';
      case 'yyyyMMddHHmmss':
        return '${now.year.toString().padLeft(4, '0')}'
            '${now.month.toString().padLeft(2, '0')}'
            '${now.day.toString().padLeft(2, '0')}'
            '${now.hour.toString().padLeft(2, '0')}'
            '${now.minute.toString().padLeft(2, '0')}'
            '${now.second.toString().padLeft(2, '0')}';
      default:
        return now.millisecondsSinceEpoch.toString();
    }
  }

  static String _hmacSHA512(String key, String data) {
    final hmac = Hmac(sha512, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  static String generateRandomString(int length, {bool onlyNumber = false}) {
    String result = '';
    String characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    if (onlyNumber) {
      characters = '0123456789';
    }
    final random = Random();
    for (int i = 0; i < length; i++) {
      result += characters[random.nextInt(characters.length)];
    }
    return result;
  }

  static bool validateCallback(Map<String, String> params) {
    final secureHash = params['vnp_SecureHash'];
    if (secureHash == null) return false;

    final filtered = Map<String, String>.from(params)
      ..remove('vnp_SecureHash')
      ..remove('vnp_SecureHashType');

    final sortedKeys = filtered.keys.toList()..sort();
    final signData = sortedKeys.map((k) => '$k=${filtered[k] ?? ''}').join('&');
    final hash = _hmacSHA512(vnpHashSecret, signData);
    return hash == secureHash;
  }
}

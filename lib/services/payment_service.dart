import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret =
      'sk_test_51H1vCtEefLDIzK0NarA3HlvO3vtYAOYNDNjtB6JuULS5woYBlzeG9fGsmdyQoXtby0yd0b68dwC0PDfvXlQkw7NU00TIOFSvSQ';
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51H1vCtEefLDIzK0NQRr58FoSgug99uMlZEeasYcOGzEZlMhW2EPC7Is7pM8uKJmTIAe1RufI46VRZdGTekfORC1Z00wghPK6cR",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency}) async {
    try {
      print('card form created and details about to be entered...');
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      print('payment intent being created...');
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      print('about to determine response...');
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      print(err.toString());
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      print(err.toString());
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(StripeService.paymentApiUrl,
          body: body, headers: StripeService.headers);
      print(response.body);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}

class PaymentBookKeepingSevice {
  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  void userDonatedToPost(String uid, String postId, double amount) {
    postsCollection
        .document(postId)
        .collection('whoDonated')
        .document(uid)
        .setData({uid: true});
    postsCollection
        .document(postId)
        .updateData({'moneyRaised': FieldValue.increment(amount)});
    userCollection
        .document(uid)
        .updateData({'amountDonated': FieldValue.increment(amount)});
    userCollection
        .document(uid)
        .collection('myDonations')
        .document(postId)
        .setData({postId: true});
  }
}

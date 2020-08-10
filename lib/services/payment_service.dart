import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';
//dcoumentation for stripe api....flutter stripe plugin is adapted from the one
//of react native. Same documentation applies.
// https://tipsi.github.io/tipsi-stripe/docs/index.html

/**Steps involved in a Stripe card payment: 
 * 
 * 1. (Server Side)Initialise Stripe with secret key in cloud functions.
 * 
 * 2. (Server Side) Create a function that is capable of creating a PaymentIntent.
 *    Doing this server side removes the need to store the secret key client 
 *    side.
 * 
 * 3 .(Client Side) Add an instance of Stripe’s CardInputWidget to 
 *    your checkout form. This is used to collect card details and ensures that the
 *    sensitive details never touch your server. You can extract a token from 
 *    this which will serve as the payment method, instead of storing the card
 *    details in your own servers. 
 * 
 *  4. (Client Side) Make a request to your server for a PaymentIntent as soon as the view
 *    loads. Store a reference to the client secret, instead of the server 
 *    passing back the entire. 
 *  
 * 5. (Client Side) Confirm payment using the PaymentIntent client secret you 
 *    collected from your server as well as the token for the payment method.
 * 
 * */

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  // static String apiBase = 'https://api.stripe.com/v1';
  // static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  // static String secret =
  //     'sk_test_51H1vCtEefLDIzK0NarA3HlvO3vtYAOYNDNjtB6JuULS5woYBlzeG9fGsmdyQoXtby0yd0b68dwC0PDfvXlQkw7NU00TIOFSvSQ';
  // static Map<String, String> headers = {
  //   'Authorization': 'Bearer ${StripeService.secret}',
  //   'Content-Type': 'application/x-www-form-urlencoded'
  // };

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
      //token from this payment method to be passed server side

      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      print('payment intent being created in backend...');

      //var https callable function to start the payment...taking in the
      //token for the payment method and the amount to be paid
      //currency will be gbp for now

      HttpsCallable createPaymentIntent = CloudFunctions.instance
          .getHttpsCallable(functionName: 'createPaymentIntent');

      print('cloud function instantiated client side...');

      HttpsCallableResult paymentIntent =
          await createPaymentIntent.call(<String, dynamic>{'amount': 888});
      //var paymentIntent =
      //    await StripeService.createPaymentIntent(amount, currency);

      //get client secret from paymentIntent object created server side

      //confirmation of payment will be done client side
      print('cloud function called');
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent.data['clientSecret'],
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

  // static Future<Map<String, dynamic>> createPaymentIntent(
  //     String amount, String currency) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': amount,
  //       'currency': currency,
  //       'payment_method_types[]': 'card'
  //     };
  //     var response = await http.post(StripeService.paymentApiUrl,
  //         body: body, headers: StripeService.headers);
  //     print(response.body);
  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     print('err charging user: ${err.toString()}');
  //   }
  //   return null;
  // }

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
        .setData({uid: true, 'amountDonated': FieldValue.increment(amount)},
            merge: true);
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
        .setData({postId: true, 'amountDonated': FieldValue.increment(amount)},
            merge: true);
  }
}

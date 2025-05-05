import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key, required int amount, required String userId, required String courtName}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('10', 'USD'); // Amount and currency

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'ShuttleZone',
          style: ThemeMode.light,
        ),
      );

      await displayPaymentSheet();

    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );
      paymentIntentData = null;
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Cancelled: ${e.error.localizedMessage}")),
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      final body = {
        'amount': (int.parse(amount) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': "sk_test_51Q7ymXRrLNtV0o2MsyL04fjPgV6Lb0aDcDrwtnbBnS35vzbsRS2Fqx4E1YyX5nyWkzKy625R18YQCGMnr6y4qqPR00ntuTD1Yl", // Replace with your Stripe Secret Key
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Failed to create payment intent: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: makePayment,
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}

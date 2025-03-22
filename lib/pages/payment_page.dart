import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final int amount;
  final String courtId;
  final String userId;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.courtId,
    required this.userId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      // Request payment intent from Firebase Cloud Function
      final response = await http.post(
        Uri.parse(
            'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/createPaymentIntent'),
        body: {'amount': widget.amount.toString()},
      );

      final jsonResponse = jsonDecode(response.body);
      paymentIntent = jsonResponse;

      // Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'ShuttleZone',
        ),
      );

      // Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful!')),
      );

      // Store Booking in Firestore
      await saveBookingToFirestore();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: $e')),
      );
    }
  }

  Future<void> saveBookingToFirestore() async {
    await FirebaseFirestore.instance.collection('Bookings').add({
      'userId': widget.userId,
      'courtId': widget.courtId,
      'amountPaid': widget.amount,
      'status': 'confirmed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: makePayment,
          child: Text('Pay Rs. ${widget.amount}'),
        ),
      ),
    );
  }
}

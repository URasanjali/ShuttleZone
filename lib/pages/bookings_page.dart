import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookings')
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            bookings = snapshot.docs.map((doc) => doc.data()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/no_bookings.png', // Replace with your "No Bookings" image asset path
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Bookings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          booking['image'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(booking['courtName'] ?? 'Court Name'),
                        subtitle:
                            Text('Date: ${booking['date'] ?? 'Unknown Date'}'),
                      ),
                    );
                  },
                ),
    );
  }
}

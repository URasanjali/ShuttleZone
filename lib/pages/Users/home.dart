import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shuttlezone/Pages/filterscreen.dart';
import 'package:shuttlezone/Pages/notificationpage.dart';
import 'package:shuttlezone/pages/courtdetails.dart';


import 'package:shuttlezone/pages/profilepage.dart';
// Import the ProfilePage here

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> courtsData = [];
  bool isLoading = true; // Initially set to true to show a loading indicator

  @override
  void initState() {
    super.initState();
    //checkAndAddUser(); // Ensure user is added to Firestore
    fetchAllCourts(); // Fetch all courts from global collection
  }

  // Fetch all courts from the global courts collection
  Future<void> fetchAllCourts() async {
    try {
      // Fetch all users in the Courtowners collection
      var usersSnapshot = await FirebaseFirestore.instance.collection('Courtowners').get();

      if (usersSnapshot.docs.isEmpty) {
        print("No users found.");
        setState(() {
          courtsData = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> allCourts = [];

      // Iterate through each user to fetch their courts
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Fetch the courts for the current user
        var courtsSnapshot = await FirebaseFirestore.instance
            .collection('Courtowners')
            .doc(userId)
            .collection('courts')
            .get();

        if (courtsSnapshot.docs.isNotEmpty) {
          for (var courtDoc in courtsSnapshot.docs) {
            final courtData = courtDoc.data();
            allCourts.add({
              'courtId': courtDoc.id,
              'name': courtData['name'] ?? 'Unnamed Court',
              'District': courtData['District'] ?? 'Unknown District',
              'image': courtData['image'] ?? 'https://example.com/default-image.jpg',
              'userId': userId, // Optionally, track the user who owns the court
            });
          }
        }
      }

      // Update the state with all courts
      setState(() {
        courtsData = allCourts;
        isLoading = false;
      });

      print('Fetched ${allCourts.length} courts.');
    } catch (e) {
      print('Error fetching courts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get auth token for the current user
  Future<String?> getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: CircleAvatar(
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : const AssetImage('assets/profile_image.jpeg') as ImageProvider,
          ),
        ),
        title: Text(
          "Hi, ${user?.displayName ?? 'User'}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Notificationpage()));
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black,
              size: 35,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Explore courts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Find court...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilterScreen(
                                  onFiltersApplied: (filters) {},
                                  courtsData: const [],
                                )));
                  },
                  icon: const Icon(Icons.filter_list),
                  color: const Color.fromARGB(255, 78, 78, 78),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Recommended Courts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : courtsData.isEmpty
                      ? const Center(child: Text("No courts available"))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: courtsData.length,
                          itemBuilder: (context, index) {
                            final court = courtsData[index];
                            final imageUrl =
                                court['image'] ?? 'https://example.com/default-image.jpg';
                            return CourtCard(
                              name: court['name'],
                              District: court['District'],
                              image: imageUrl,
                              userId: court['userId'],
                              courtId: court['courtId'],
                              courtDistrict: court['District'],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B7340),
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B7340),
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) async {
          String? authToken = await getAuthToken();
          switch (index) {
            case 0:
              // Navigate to Home page (if needed)
              break;
            case 1:
              // Navigate to Bookings page (if needed)
              break;
            case 2:
              // Navigate to Profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class CourtCard extends StatelessWidget {
  final String name;
  final String District;
  final String image;
  final String courtId;
  final String userId;
  final String courtDistrict;

  const CourtCard({
    super.key,
    required this.name,
    required this.District,
    required this.image,
    required this.courtId,
    required this.userId,
    required this.courtDistrict,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          // Navigate to CourtDetail page with the actual values
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Courtdetails(
                userId: userId, // Pass actual userId
                courtId: courtId, courtDistrict: '', name: '', district: '', image: '', courtName: '', // Pass actual courtId
              ),
            ),
          );
        },
        child: SizedBox(
          height: 300, // Adjust the height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  height: 110,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  District,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to CourtDetail page with the actual values
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Courtdetails(
                          userId: userId,
                          courtId: courtId, courtDistrict: '', name: '', district: '', image: '', courtName: '',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7340),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Additional space if needed
            ],
          ),
        ),
      ),
    );
  }
}

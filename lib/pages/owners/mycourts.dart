import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shuttlezone/pages/owners/createcourt.dart';
import 'package:shuttlezone/pages/owners/editcourt.dart';

class MyCourtsScreen extends StatefulWidget {
  final String userId;
  final String? authToken;

  const MyCourtsScreen({super.key, required this.userId, this.authToken});

  @override
  _MyCourtsScreenState createState() => _MyCourtsScreenState();
}

class _MyCourtsScreenState extends State<MyCourtsScreen> {
  List<DocumentSnapshot> courts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourts();
  }

  // Fetch courts from Firestore
  Future<void> fetchCourts() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Courtowners')
          .doc(widget.userId)
          .collection('courts')
          .get();

      setState(() {
        courts = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "My Courts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // "Create+" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateCourtScreen()),
                ).then((_) => fetchCourts()); // Refresh after returning
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7340),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Create+",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : courts.isEmpty
                    ? const Center(
                        child: Text(
                          "No courts added yet",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: courts.length,
                        itemBuilder: (context, index) {
                          final courtData = courts[index].data() as Map<String, dynamic>? ?? {};
                          final imageUrl = courtData['image'] ?? '';
                          final name = courtData['name'] ?? 'Unnamed Court';
                          final District = courtData['District'] ?? 'Unknown District';

                          return CourtCard(
                            title: name,
                            District: District,
                            imageUrl: imageUrl,
                            onEditPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCourtScreen(
                                    courtId: courts[index].id,
                                    initialName: name,
                                    initialDistrict: District,
                                    initialDescription: courtData['description'] ?? '',
                                    userId: widget.userId,
                                  ),
                                ),
                              ).then((_) => fetchCourts());
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// CourtCard Widget
class CourtCard extends StatelessWidget {
  final String title;
  final String District;
  final String imageUrl;
  final VoidCallback onEditPressed;

  const CourtCard({
    super.key,
    required this.title,
    required this.District,
    required this.imageUrl,
    required this.onEditPressed
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display court image with caching
          imageUrl.isNotEmpty
              ? Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.image, color: Colors.grey[600])),
                ),
          // Display court title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // Display court location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              District,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          // Display edit button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: onEditPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7340),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "Edit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
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
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true, // Ensure the title is centered
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture
            const CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xFF1B7340),
              child: CircleAvatar(
                radius: 68,
                backgroundImage: AssetImage('assets/profile_image.jpeg'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  // Implement edit profile picture functionality
                },
                child: const Text('Edit', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),
            // Text Fields
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Log Out Button
            ElevatedButton(
              onPressed: () {
                // Implement logout functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Log Out Button Color
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child:
                  const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Save Changes Button
            ElevatedButton(
              onPressed: () {
                // Implement save changes functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF1B7340), // Save Changes Button Color
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // For logout functionality

// import 'package:shuttlezone/pages/authpages/login.dart';


// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _bioController = TextEditingController();

//   String? _profileImageUrl; // Store the Cloudinary URL instead of File

//   final ImagePicker _picker = ImagePicker(); // Image picker instance

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       // Upload the image to Cloudinary and get the URL
//       final imageUrl = await _uploadImageToCloudinary(pickedFile.path);
//       setState(() {
//         _profileImageUrl = imageUrl;
//       });
//     }
//   }

//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       // Upload the image to Cloudinary and get the URL
//       final imageUrl = await _uploadImageToCloudinary(pickedFile.path);
//       setState(() {
//         _profileImageUrl = imageUrl;
//       });
//     }
//   }

//   Future<String> _uploadImageToCloudinary(String imagePath) async {
//     // Implement Cloudinary upload logic here
//     // This is a placeholder function. Replace it with your actual Cloudinary upload code.
//     // Example:
//     // final response = await Cloudinary.upload(imagePath);
//     // return response.url;

//     // For now, return a dummy URL
//     return 'https://res.cloudinary.com/your-cloud-name/image/upload/v1234567/your-image.jpg';
//   }

// Future<void> _saveProfile() async {
//   String firstName = _firstNameController.text.trim();
//   String lastName = _lastNameController.text.trim();
//   String username = _usernameController.text.trim();
//   String location = _locationController.text.trim();
//   String bio = _bioController.text.trim();

//   if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || location.isEmpty || bio.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('All fields are required!')),
//     );
//     return;
//   }

//   try {
//     // Save profile data in Firestore to the 'profiles' collection, not 'users'
//     await FirebaseFirestore.instance.collection('profiles').add({
//       'firstName': firstName,
//       'lastName': lastName,
//       'username': username,
//       'location': location,
//       'bio': bio,
//       'profileImage': _profileImageUrl ?? 'No Image Selected', // Use Cloudinary URL
//       'timestamp': FieldValue.serverTimestamp(), // Add timestamp
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile Saved to Firebase!')),
//     );

//     // Clear the form after saving
//     _firstNameController.clear();
//     _lastNameController.clear();
//     _usernameController.clear();
//     _locationController.clear();
//     _bioController.clear();
//     setState(() {
//       _profileImageUrl = null;
//     });
//   } catch (e) {
//     print('Error saving profile: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to save profile: $e')),
//     );
//   }
// }


//   // Log out function
// void _logOut() async {
//   try {
//     await FirebaseAuth.instance.signOut();
//     // Navigate to the Login screen after logout
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => Login(showScreen4: () {  }, showSignUp: () {  }, showLogin: () {  },)),
//     );
//   } catch (e) {
//     print('Error logging out: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Failed to log out')),
//     );
//   }
// }



//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _usernameController.dispose();
//     _locationController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.white), // White text for the app bar title
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF09663F), // Updated to #09663F
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickImage,
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundImage: _profileImageUrl != null
//                         ? NetworkImage(_profileImageUrl!) // Use NetworkImage for URLs
//                         : null,
//                     child: _profileImageUrl == null
//                         ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'First Name',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your first name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF09663F), width: 2), // Updated to #09663F
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Last Name',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your last name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF09663F), width: 2), // Updated to #09663F
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Username',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF09663F), width: 2), // Updated to #09663F
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Location',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _locationController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your location',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF09663F), width: 2), // Updated to #09663F
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Bio',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _bioController,
//                 decoration: InputDecoration(
//                   hintText: 'Tell us about yourself',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFF09663F), width: 2), // Updated to #09663F
//                   ),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 24),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF09663F), // Updated to #09663F
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Profile',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: ElevatedButton.icon(
//                   onPressed: _takePhoto,
//                   icon: const Icon(Icons.camera_alt, color: Colors.white),
//                   label: const Text(
//                     'Take Photo',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF09663F), // Updated to #09663F
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Center(
//               //   child: ElevatedButton.icon(
//               //     onPressed: () => Navigator.push(
//               //       context,
//               //       MaterialPageRoute(
//               //         builder: (context) => const ProfilesListPage(),
//               //       ),
//               //     ),
//               //     icon: const Icon(Icons.list, color: Colors.white),
//               //     label: const Text(
//               //       'View Profiles',
//               //       style: TextStyle(fontSize: 16, color: Colors.white),
//               //     ),
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: const Color(0xFF09663F), // Updated to #09663F
//               //       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(10),
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               const SizedBox(height: 24),
//               // Log Out button at the bottom
//               Center(
//                 child: TextButton(
//                   onPressed: _logOut,
//                   child: const Text(
//                     'Log Out',
//                     style: TextStyle(fontSize: 16, color: Colors.red), // Red text for Log Out
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shuttlezone/pages/authpages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String username;
  late String email;
  late String role;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Fetch user data from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(role == 'Court Owner' ? 'Courtowners' : 'Court Booker')
        .doc(_user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        username = userDoc['username'];
        email = userDoc['email'];
        role = userDoc['role'];
      });
    } else {
      // Handle case where user data is not found
      setState(() {
        username = 'N/A';
        email = 'N/A';
        role = 'N/A';
      });
    }
  }

  Future<void> _logOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login(showScreen4: () {  }, showSignUp: () {  }, showLogin: () {  },)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Username: $username',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: $email',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Role: $role',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logOut,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

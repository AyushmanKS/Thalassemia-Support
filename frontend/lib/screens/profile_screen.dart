import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  void _logout(BuildContext context) {
    // Push login screen and remove all other routes from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.red[100],
                child: Icon(
                  user['role'] == 'donor' ? Icons.favorite : Icons.person,
                  size: 60,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 20),
              Text(
                user['username'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Chip(
                label: Text(
                  '${user['role']}'.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: user['role'] == 'donor' ? Colors.blueAccent : Colors.green,
              ),
              SizedBox(height: 40),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.bloodtype, color: Colors.redAccent),
                  title: Text('Blood Type'),
                  trailing: Text(
                    user['blood_type'] ?? 'N/A',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Spacer(), // Pushes the logout button to the bottom
              ElevatedButton.icon(
                icon: Icon(Icons.logout),
                onPressed: () => _logout(context),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50), // Full width button
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
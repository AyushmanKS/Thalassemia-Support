import 'package:flutter/material.dart';
import 'package:frontend/screens/health_vault_screen.dart'; // <-- THIS IMPORT IS CRUCIAL
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/provider_chat_screen.dart'; // <-- THIS IMPORT IS ALSO CRUCIAL

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
    final isPatient = user['role'] == 'patient';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes back button from AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red[100],
              child: Icon(
                isPatient ? Icons.person : Icons.favorite,
                size: 50,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              user['username'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // --- Info and Action Cards ---
            _buildInfoCard(Icons.bloodtype, 'Blood Type', user['blood_type'] ?? 'N/A'),
            
            if (isPatient) ...[
              SizedBox(height: 10),
              _buildActionCard(
                Icons.shield, 
                'Digital Health Vault', 
                context, 
                () => HealthVaultScreen(user: user) // Correct usage
              ),
              SizedBox(height: 10),
              _buildActionCard(
                Icons.chat_bubble, 
                'Chat with Provider', 
                context, 
                () => ProviderChatScreen(user: user) // Correct usage
              ),
            ],
            
            Spacer(), // Pushes logout button to the bottom
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for basic info cards
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // Helper widget for cards that navigate to another screen
  Widget _buildActionCard(IconData icon, String title, BuildContext context, Widget Function() screenBuilder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => screenBuilder(),
          ));
        },
      ),
    );
  }
}
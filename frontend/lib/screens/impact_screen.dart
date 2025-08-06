import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class ImpactScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ImpactScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extracting user data with defaults for safety
    final civicScore = user['civic_score'] ?? 0;
    final donations = user['donations'] ?? 0;
    final role = user['role'] ?? 'patient';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2c3e50), Color(0xFF3498db)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: role == 'donor'
                ? _buildDonorImpactView(civicScore, donations)
                : _buildPatientImpactView(),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientImpactView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, color: Colors.white.withOpacity(0.8), size: 80),
          SizedBox(height: 20),
          Text(
            'Our Community Thanks You',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            'Donors are here to support you. This screen shows their impact and rewards.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorImpactView(int civicScore, int donations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Your Impact', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 30),
        GlassContainer.clearGlass(
          height: 200,
          width: double.infinity,
          borderRadius: BorderRadius.circular(25),
          blur: 15,
          borderColor: Colors.white.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Civic Respect Score', style: TextStyle(fontSize: 20, color: Colors.white70)),
              SizedBox(height: 10),
              Text(
                civicScore.toString(),
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: GlassContainer.clearGlass(
                height: 100,
                borderRadius: BorderRadius.circular(20),
                blur: 15,
                borderColor: Colors.white.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Donations', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text(donations.toString(), style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: GlassContainer.clearGlass(
                height: 100,
                borderRadius: BorderRadius.circular(20),
                blur: 15,
                borderColor: Colors.white.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lives Saved', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text((donations * 3).toString(), style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Text('Badges Earned', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildBadge(Icons.bloodtype, 'First Drop', donations >= 1),
            _buildBadge(Icons.star, '5 Donations', donations >= 5),
            _buildBadge(Icons.shield, 'Hero Donor', donations >= 10),
            _buildBadge(Icons.military_tech, 'Legend', donations >= 20),
          ],
        )
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, bool isEarned) {
    return Opacity(
      opacity: isEarned ? 1.0 : 0.3,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isEarned ? Colors.amber : Colors.grey[700],
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
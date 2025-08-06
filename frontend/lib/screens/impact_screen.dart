import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImpactScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ImpactScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check the user's role to display the correct view
    return Scaffold(
      backgroundColor: Color(0xff1a1a2e), // A deep, premium navy blue
      body: SafeArea(
        child: user['role'] == 'donor'
            ? _buildDonorJourneyView(context)
            : _buildPatientImpactView(context),
      ),
    );
  }

  // A clear and respectful view for patients
  Widget _buildPatientImpactView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, color: Colors.tealAccent, size: 80),
            SizedBox(height: 20),
            Text(
              'The Donor Journey',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'This is where our heroic donors see their roadmap of impact. Every donation is a milestone in saving lives.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // The main, impressive Gamification UI for Donors
  Widget _buildDonorJourneyView(BuildContext context) {
    final int donationCount = user['donations'] ?? 0;
    final int civicScore = user['civic_score'] ?? 0;

    // Define which milestones are unlocked
    final bool milestone1 = donationCount >= 1;
    final bool milestone2 = donationCount >= 5;
    final bool milestone3 = civicScore >= 500;
    final bool milestone4 = donationCount >= 10;

    return Column(
      children: [
        // --- TOP HERO SECTION ---
        Container(
          padding: EdgeInsets.all(24),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff16213e), Color(0xff0f3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Your Journey as a Blood Warrior',
                style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Donations', donationCount.toString(), Icons.bloodtype, Colors.redAccent),
                  _buildStatColumn('Lives Saved', (donationCount * 3).toString(), Icons.favorite, Colors.pinkAccent),
                  _buildStatColumn('Civic Score', civicScore.toString(), Icons.shield, Colors.amber),
                ],
              ),
            ],
          ),
        ),
        
        // --- DONOR ROADMAP ---
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              _buildRoadmapTile(
                icon: Icons.flag,
                title: 'The Journey Begins',
                subtitle: 'Register as a Blood Warrior.',
                isUnlocked: true, // Always unlocked
              ),
              _buildRoadmapTile(
                icon: Icons.water_drop,
                title: 'First Drop of Life',
                subtitle: 'Complete your first donation.',
                isUnlocked: milestone1,
                points: '+50 Civic Score',
              ),
              _buildRoadmapTile(
                icon: Icons.star,
                title: 'Bronze Heart',
                subtitle: 'Complete 5 total donations.',
                isUnlocked: milestone2,
                points: '+100 Civic Score',
              ),
              _buildRoadmapTile(
                icon: Icons.military_tech,
                title: 'Community Pillar',
                subtitle: 'Achieve a Civic Score of 500.',
                isUnlocked: milestone3,
                points: 'Unlock new rewards',
              ),
              _buildRoadmapTile(
                icon: Icons.shield,
                title: 'Thalassemia Shield',
                subtitle: 'Complete 10 total donations.',
                isUnlocked: milestone4,
                points: 'A true hero!',
              ),
              _buildRoadmapTile(
                icon: Icons.diamond,
                title: 'Diamond Donor',
                subtitle: 'The next level of impact awaits.',
                isUnlocked: false, // Future goal
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for the top stats
  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(value, style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  // Helper widget for each milestone on the roadmap
  Widget _buildRoadmapTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUnlocked,
    String? points,
  }) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            // The Icon and line
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked ? Colors.tealAccent : Colors.grey[800],
                    border: Border.all(color: isUnlocked ? Colors.tealAccent : Colors.grey[700]!, width: 2),
                  ),
                  child: Icon(icon, color: isUnlocked ? Color(0xff1a1a2e) : Colors.grey[500]),
                ),
                // The vertical line connecting the dots
                Container(height: 50, width: 2, color: isUnlocked ? Colors.tealAccent.withOpacity(0.5) : Colors.grey[800]),
              ],
            ),
            SizedBox(width: 15),
            // The Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
                  ),
                  if (isUnlocked && points != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        points,
                        style: GoogleFonts.lato(fontSize: 12, color: Colors.tealAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
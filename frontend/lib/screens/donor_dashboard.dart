import 'package:flutter/material.dart';
import 'package:frontend/screens/blood_bank_screen.dart';

class DonorDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  DonorDashboard({required this.user});

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Donor Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.business, color: Colors.deepPurple),
                  title: Text('Live Blood Bank Status'),
                  subtitle: Text('Check stock levels across the city'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => BloodBankScreen())),
                ),
              ),
              SizedBox(height: 20),
              Text('This dashboard can be expanded with more donor-specific features.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
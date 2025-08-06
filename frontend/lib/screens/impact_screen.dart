import 'package:flutter/material.dart';

class ImpactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Impact'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[400]!, Colors.red[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text('Lives Saved'),
                trailing: Text('5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('Points'),
                trailing: Text('1250', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
            Text('Badges'),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                Chip(avatar: Icon(Icons.bloodtype), label: Text('First Donation')),
                Chip(avatar: Icon(Icons.military_tech), label: Text('Top Donor')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
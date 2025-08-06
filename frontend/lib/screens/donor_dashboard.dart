import 'package:flutter/material.dart';
import 'package:frontend/screens/impact_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DonorDashboard extends StatefulWidget {
    final Map<String, dynamic> user;
  DonorDashboard({required this.user});

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/requests'));
    if (response.statusCode == 200) {
      setState(() {
        _requests = json.decode(response.body);
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donor Dashboard'),
         flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[400]!, Colors.red[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImpactScreen()));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.bloodtype, color: Colors.red),
              title: Text('Blood Request: ${request['blood_type']}'),
              subtitle: Text('Status: ${request['status']}'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text('Accept'),
              ),
            ),
          );
        },
      ),
    );
  }
}
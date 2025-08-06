import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({Key? key}) : super(key: key);

  @override
  _BloodBankScreenState createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  List<dynamic> _bloodBanks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/blood_bank_status'));
      if (response.statusCode == 200) {
        setState(() => _bloodBanks = json.decode(response.body));
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Color _getStockColor(int count) {
    if (count > 20) return Colors.green;
    if (count > 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Blood Bank Status'), backgroundColor: Colors.deepPurple),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStatus,
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _bloodBanks.length,
                itemBuilder: (context, index) {
                  final bank = _bloodBanks[index];
                  return Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bank['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(bank['city'], style: TextStyle(color: Colors.grey)),
                          Divider(),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: (bank['stock'] as Map<String, dynamic>).entries.map((entry) {
                              return Chip(
                                label: Text('${entry.key}: ${entry.value}'),
                                backgroundColor: _getStockColor(entry.value),
                                labelStyle: TextStyle(color: Colors.white),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
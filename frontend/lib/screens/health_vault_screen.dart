import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthVaultScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HealthVaultScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HealthVaultScreenState createState() => _HealthVaultScreenState();
}

class _HealthVaultScreenState extends State<HealthVaultScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/health_records/${widget.user['id']}'));
      if (response.statusCode == 200) {
        setState(() => _records = json.decode(response.body));
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddRecordDialog() {
    final _titleController = TextEditingController();
    final _detailsController = TextEditingController();
    String _selectedType = 'Blood Report';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Health Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['Blood Report', 'Transfusion Passport', 'Medication', 'Doctor Note']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) => _selectedType = value!,
              ),
              TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: _detailsController, decoration: InputDecoration(labelText: 'Details / Values')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _addRecord(_selectedType, _titleController.text, _detailsController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRecord(String type, String title, String details) async {
    try {
      await http.post(
        Uri.parse('http://10.0.2.2:5000/api/health_records'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': widget.user['id'],
          'record_type': type,
          'title': title,
          'details': details,
        }),
      );
      _fetchRecords(); // Refresh the list
    } catch (e) {
      // Handle error
    }
  }
  
  IconData _getIconForRecordType(String recordType) {
    switch (recordType) {
      case 'Blood Report': return Icons.science;
      case 'Transfusion Passport': return Icons.bloodtype;
      case 'Medication': return Icons.medication;
      default: return Icons.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Health Vault'), backgroundColor: Colors.indigo),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRecords,
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(_getIconForRecordType(record['record_type']), color: Colors.indigo, size: 40),
                      title: Text(record['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(record['details']),
                      trailing: Text(record['record_date']),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecordDialog,
        icon: Icon(Icons.add),
        label: Text('Add Record'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
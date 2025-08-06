import 'package:flutter/material.dart';

class ArticleScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article['category']), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Text(article['content'], style: TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
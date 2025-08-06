import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/article_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/education_content'));
      if (response.statusCode == 200) {
        setState(() {
          _articles = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thalassemia Education'), backgroundColor: Colors.teal),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(10),
              children: _buildArticleList(),
            ),
    );
  }

  List<Widget> _buildArticleList() {
    Map<String, List<dynamic>> groupedArticles = {};
    for (var article in _articles) {
      groupedArticles.putIfAbsent(article['category'], () => []).add(article);
    }

    List<Widget> widgets = [];
    groupedArticles.forEach((category, articles) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 8.0, bottom: 8.0),
          child: Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        ),
      );
      widgets.addAll(articles.map((article) => Card(
            elevation: 2,
            child: ListTile(
              title: Text(article['title']),
              subtitle: Text(article['summary']),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ArticleScreen(article: article),
              )),
            ),
          )));
    });
    return widgets;
  }
}
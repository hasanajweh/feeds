import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedsScreen extends StatefulWidget {
  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final response = await http.get(Uri.parse('http://feeds.ppu.edu/courses'));

    if (response.statusCode == 200) {
      setState(() {
        _courses = json.decode(response.body);
        _isLoading = false;
      });
    }
  }

  Future<void> subscribeCourse(int courseId) async {
    // Subscription logic here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feeds')),
      drawer: NavigationDrawer(children: [],),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return ListTile(
                  title: Text(course['name']),
                  subtitle: Text('${course['lecturer']} - ${course['college']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => subscribeCourse(course['id']),
                  ),
                );
              },
            ),
    );
  }
}

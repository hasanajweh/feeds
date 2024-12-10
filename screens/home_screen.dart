import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<dynamic> subscribedCourses = [
    {'name': 'Math 101', 'lecturer': 'Dr. John', 'college': 'Science'},
    {'name': 'Physics 202', 'lecturer': 'Dr. Smith', 'college': 'Science'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'PPU Feeds',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Feeds'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/feeds');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: subscribedCourses.length,
        itemBuilder: (context, index) {
          final course = subscribedCourses[index];
          return ListTile(
            title: Text(course['name']),
            subtitle: Text('${course['lecturer']} - ${course['college']}'),
            onTap: () {
              Navigator.pushNamed(context, '/course_feed');
            },
          );
        },
      ),
    );
  }
}

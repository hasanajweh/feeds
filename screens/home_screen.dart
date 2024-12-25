import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/home_service.dart';
import 'package:ppu_feeds/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  List<dynamic> subscriptions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    try {
      setState(() => isLoading = true);
      subscriptions = await _homeService.fetchSubscriptions();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> refreshSubscriptions() async {
    fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      drawer: AppDrawer(), 
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : subscriptions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No Subscribed Courses',
                              style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              sub['course'] ?? 'Unnamed Course',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                '${sub['section'] ?? ''} - ${sub['lecturer'] ?? ''}'),
                            leading: Icon(Icons.bookmark, color: Colors.blue),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/course_feed',
                                arguments: {'sectionId': sub['section_id']},
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

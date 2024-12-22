import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/feeds_service.dart';

class FeedsScreen extends StatefulWidget {
  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  final FeedsService _service = FeedsService();
  List<dynamic> courses = [];
  List<dynamic> subscriptions = [];
  Map<int, List<dynamic>> sectionsMap = {};
  Set<int> expandedCourses = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      setState(() => isLoading = true);
      courses = await _service.fetchCourses();
      subscriptions = await _service.fetchSubscriptions();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchSections(int courseId) async {
    try {
      final sections = await _service.fetchSections(courseId);
      setState(() {
        sectionsMap[courseId] = sections;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> toggleSubscription(
    int courseId,
    int sectionId,
    bool isSubscribed,
    {int? subscriptionId}
  ) async {
    try {
      await _service.toggleSubscription(courseId, sectionId, isSubscribed, subscriptionId: subscriptionId);
      fetchAllData(); // Refresh data after toggling
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feeds')),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: fetchAllData,
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final courseId = course['id'];

                      return Column(
                        children: [
                          ListTile(
                            title: Text(course['name'] ?? 'Unnamed Course'),
                            subtitle: Text('${course['college'] ?? ''}'),
                            trailing: IconButton(
                              icon: Icon(
                                expandedCourses.contains(courseId)
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              onPressed: () async {
                                if (!expandedCourses.contains(courseId)) {
                                  await fetchSections(courseId);
                                }
                                setState(() {
                                  if (expandedCourses.contains(courseId)) {
                                    expandedCourses.remove(courseId);
                                  } else {
                                    expandedCourses.add(courseId);
                                  }
                                });
                              },
                            ),
                          ),
                          if (expandedCourses.contains(courseId)) ...sectionsMap[courseId]?.map<Widget>((section) {
                            final subscription = subscriptions.firstWhere(
                              (sub) => sub['section'] == section['name'],
                              orElse: () => null,
                            );
                            final isSubscribed = subscription != null;
                            final subscriptionId = subscription?['id'];

                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                title: Text('Section: ${section['name'] ?? ''}'),
                                subtitle: Text(
                                  'Lecturer: ${section['lecturer'] ?? ''}\nCollege: ${course['college'] ?? ''}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isSubscribed ? Icons.check_circle : Icons.add_circle_outline,
                                    color: isSubscribed ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    await toggleSubscription(
                                      courseId,
                                      section['id'],
                                      isSubscribed,
                                      subscriptionId: subscriptionId,
                                    );
                                  },
                                ),
                              ),
                            );
                          }) ?? [],
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}

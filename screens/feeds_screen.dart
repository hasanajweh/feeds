import 'package:flutter/material.dart';
import 'package:ppu_feeds/Services/feeds_service.dart';
import 'package:ppu_feeds/app_drawer.dart';

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
    bool isSubscribed, {
    int? subscriptionId,
  }) async {
    try {
      await _service.toggleSubscription(courseId, sectionId, isSubscribed,
          subscriptionId: subscriptionId);
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
      appBar: AppBar(
        title: Text('Feeds'),
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
              : RefreshIndicator(
                  onRefresh: fetchAllData,
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final courseId = course['id'];

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          key: Key(courseId.toString()),
                          leading: Icon(Icons.book, color: Colors.blue),
                          title: Text(
                            course['name'] ?? 'Unnamed Course',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${course['college'] ?? ''}'),
                          children: sectionsMap[courseId]
                                  ?.map<Widget>((section) {
                                final subscription = subscriptions.firstWhere(
                                  (sub) => sub['section'] == section['name'],
                                  orElse: () => null,
                                );
                                final isSubscribed = subscription != null;
                                final subscriptionId = subscription?['id'];

                                return ListTile(
                                  title: Text('Section: ${section['name'] ?? ''}'),
                                  subtitle: Text(
                                    'Lecturer: ${section['lecturer'] ?? ''}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isSubscribed
                                          ? Icons.check_circle
                                          : Icons.add_circle_outline,
                                      color:
                                          isSubscribed ? Colors.green : Colors.grey,
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
                                );
                              })
                                  .toList() ?? [],
                          onExpansionChanged: (isExpanded) async {
                            if (isExpanded) {
                              await fetchSections(courseId);
                            }
                            setState(() {
                              if (isExpanded) {
                                expandedCourses.add(courseId);
                              } else {
                                expandedCourses.remove(courseId);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

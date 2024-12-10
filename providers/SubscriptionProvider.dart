import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionProvider with ChangeNotifier {
  List<dynamic> _subscriptions = [];

  List<dynamic> get subscriptions => _subscriptions;

  Future<void> fetchSubscriptions(String token) async {
    final response = await http.get(
      Uri.parse('http://feeds.ppu.edu/api/v1/subscriptions'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      _subscriptions = json.decode(response.body)['subscriptions'];
      notifyListeners();
    }
  }
}

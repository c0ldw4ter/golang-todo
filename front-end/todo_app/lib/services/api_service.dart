import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';

class ApiService {
  final String baseUrl = "http://localhost:8080";

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      print('Failed to load tasks: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      print('Failed to create task: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      print('Failed to update task: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
    );
    if (response.statusCode != 200) {
      print('Failed to delete task: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete task');
    }
  }
}

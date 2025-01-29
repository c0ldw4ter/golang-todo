import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskList(),
    );
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final ApiService apiService = ApiService();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await apiService.getTasks();
      setState(() {
        this.tasks = tasks;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTask() async {
    final newTask = Task(id: '', title: 'New Task', completed: false);
    await apiService.createTask(newTask);
    fetchTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.completed = !task.completed;
    await apiService.updateTask(task);
    fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    await apiService.deleteTask(id);
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            trailing: Checkbox(
              value: task.completed,
              onChanged: (value) {
                toggleTaskCompletion(task);
              },
            ),
            onLongPress: () {
              deleteTask(task.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}

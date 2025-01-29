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
    final newTask =
        Task(id: '', title: 'New Task', description: '', completed: false);
    await apiService.createTask(newTask);
    fetchTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.completed = !task.completed;
    await apiService.updateTask(task);
    fetchTasks();
  }

  Future<void> editTask(Task task) async {
    // Открываем диалоговое окно для редактирования задачи
    final updatedTask = await showDialog<Task>(
      context: context,
      builder: (context) =>
          EditTaskDialog(task: task, onDelete: () => deleteTask(task.id)),
    );

    if (updatedTask != null) {
      await apiService.updateTask(updatedTask);
      fetchTasks();
    }
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
            subtitle:
                task.description.isNotEmpty ? Text(task.description) : null,
            trailing: Checkbox(
              value: task.completed,
              onChanged: (value) {
                toggleTaskCompletion(task);
              },
            ),
            onLongPress: () {
              deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Task deleted")),
              );
            },
            onTap: () {
              editTask(task);
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

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;

  EditTaskDialog({required this.task, required this.onDelete});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _completed = widget.task.completed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Edit Task'),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLines: null, // Позволяем многострочный ввод
            decoration: InputDecoration(labelText: 'Description'),
          ),
          CheckboxListTile(
            title: Text('Completed'),
            value: _completed,
            onChanged: (value) {
              setState(() {
                _completed = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedTask = Task(
              id: widget.task.id,
              title: _titleController.text,
              description: _descriptionController.text,
              completed: _completed,
            );
            Navigator.of(context).pop(updatedTask);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

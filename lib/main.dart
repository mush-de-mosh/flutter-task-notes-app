import 'package:flutter/material.dart';
import 'services/theme_service.dart';
import 'services/database_helper.dart';
import 'models/task_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final isDark = await ThemeService.isDarkTheme();
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  void toggleTheme(bool isDark) async {
    await ThemeService.setDarkTheme(isDark);
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Notes Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeToggle: toggleTheme, isDarkTheme: _isDarkTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

  final Function(bool) onThemeToggle;
  final bool isDarkTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
    _loadTasks();
  }

  void _testDatabaseConnection() async {
    final isConnected = await DatabaseHelper().testConnection();
    if (isConnected) {
      print('Database connection successful!');
    } else {
      print('Database connection failed!');
    }
  }

  void _loadTasks() async {
    try {
      print('Loading tasks from database...');
      final tasks = await DatabaseHelper().getAllTasks();
      print('Loaded ${tasks.length} tasks');
      for (var task in tasks) {
        print('Task: ${task.title} - ${task.priority}');
      }
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      // Fallback to empty list if database fails
      setState(() {
        _tasks = [];
      });
    }
  }

  void _deleteTask(String id) async {
    try {
      print(' Deleting task with id: $id');
      final result = await DatabaseHelper().deleteTask(id);
      print(' Task deleted successfully. Rows affected: $result');
      _loadTasks(); // Refresh the list
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Task Notes Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'My Tasks & Notes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Tasks: ${_tasks.length}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: widget.isDarkTheme,
            onChanged: widget.onThemeToggle,
            secondary: Icon(widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: Text(task.title),
                  subtitle: Text('Priority: ${task.priority}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(task.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Low';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Task/Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ['Low', 'Medium', 'High']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitTask,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTask() async {
    if (_titleController.text.isEmpty) {
      print('Cannot submit: Title is empty');
      return;
    }
    
    try {
      final task = TaskItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        priority: _priority,
        description: _descriptionController.text,
        isCompleted: false,
      );
      
      print('Submitting task: ${task.title} (Priority: ${task.priority})');
      final result = await DatabaseHelper().insertTask(task);
      print('Task inserted successfully with result: $result');
      
      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _priority = 'Low';
      });
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error inserting task: $e');
    }
  }
}

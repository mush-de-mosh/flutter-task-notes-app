import 'package:flutter/material.dart';
import 'services/theme_service.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

  final Function(bool) onThemeToggle;
  final bool isDarkTheme;

  final List<String> sampleTasks = const [
    'Complete Flutter assignment',
    'Review Git best practices',
    'Prepare for project presentation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Task Notes Manager'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Tasks & Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: isDarkTheme,
            onChanged: onThemeToggle,
            secondary: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sampleTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: Text(sampleTasks[index]),
                  trailing: const Icon(Icons.arrow_forward_ios),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondScreen()),
          );
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

  void _submitTask() {
    print('Task submitted: ${_titleController.text}');
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _filters = ['Today', 'Upcoming', 'Done'];
  late String _filter;

  @override
  void initState() {
    super.initState();
    _filter = context.read<SettingsProvider>().defaultFilter;
  }

  void _openForm([task]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = provider.forFilter(_filter);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My tasks'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context
                .read<SettingsProvider>()
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: _filters.map((f) {
                final selected = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$f (${provider.countFor(f)})'),
                    selected: selected,
                    selectedColor: scheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? scheme.onPrimary : null,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _filter == 'Done'
                      ? 'No completed tasks yet.'
                      : 'Nothing here. Tap "Add task" to create one.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: scheme.onError),
                  ),
                  onDismissed: (_) {
                    provider.remove(task.id);
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: const Text('Task deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => provider.add(task),
                          ),
                        ),
                      );
                  },
                  child: TaskTile(
                    task: task,
                    onToggle: () => provider.toggleDone(task.id),
                    onTap: () => _openForm(task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _openForm,
            icon: const Icon(Icons.add),
            label: const Text('Add task'),
          ),
        ),
      ),
    );
  }
}
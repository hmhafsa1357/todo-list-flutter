import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Used for both creating a new task and editing an existing one.
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const TaskFormScreen({super.key, this.task, this.initialDate});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const _priorities = ['High', 'Med', 'Low'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  late String _priority;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _dueDate = _isEditing
        ? widget.task!.dueDate
        : (widget.initialDate ?? DateTime.now());
    _priority = widget.task?.priority ?? 'Med';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim();

    if (_isEditing) {
      provider.update(widget.task!.copyWith(
        title: title,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        priority: _priority,
      ));
    } else {
      provider.add(Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        dueDate: _dueDate,
        priority: _priority,
      ));
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<TaskProvider>().remove(widget.task!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit task' : 'New task'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete task',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Title'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                  const InputDecoration(hintText: 'e.g. Buy groceries'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Due date'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      suffixIcon: _dueDate == null
                          ? const Icon(Icons.calendar_today, size: 18)
                          : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'No due date'
                          : formatDate(_dueDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Priority'),
                const SizedBox(height: 8),
                Row(
                  children: _priorities.map((p) {
                    final selected = p == _priority;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(p, textAlign: TextAlign.center),
                          ),
                          selected: selected,
                          selectedColor: scheme.primary,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: selected ? scheme.onPrimary : null,
                          ),
                          onSelected: (_) => setState(() => _priority = p),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
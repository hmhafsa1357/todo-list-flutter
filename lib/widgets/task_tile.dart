import 'package:flutter/material.dart';
import '../models/task.dart';

/// One task row: round checkbox, title, due date and priority tag.
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHigh = task.priority == 'High';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone ? scheme.primary : Colors.transparent,
              border: Border.all(color: scheme.primary, width: 1.5),
            ),
            child: task.isDone
                ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Theme.of(context).hintColor : null,
          ),
        ),
        subtitle: task.dueDate == null ? null : Text(formatDate(task.dueDate!)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isHigh
                ? scheme.primary.withValues(alpha: 0.15)
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            task.priority,
            style: TextStyle(
              fontSize: 11,
              color: isHigh ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
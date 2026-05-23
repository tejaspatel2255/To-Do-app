import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/todo_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // To allow custom glassmorphism inside
      builder: (context) => const TodoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.todos;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF111827), const Color(0xFF1F2937)]
                : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFilterRow(context, provider)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: 0.1, end: 0),
              Expanded(
                child: todos.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return TodoItem(todo: todos[index])
                              .animate()
                              .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildFilterRow(BuildContext context, TodoProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', provider),
          const SizedBox(width: 8),
          _buildFilterChip('Active', provider),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', provider),
          const SizedBox(width: 16),
          Container(height: 30, width: 2, color: Theme.of(context).dividerColor),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.categoryFilter,
                icon: const Icon(Icons.filter_list, size: 18),
                isDense: true,
                style: Theme.of(context).textTheme.bodyMedium,
                items: ['All', 'None', 'Work', 'Personal', 'Shopping', 'Others']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) provider.setCategoryFilter(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TodoProvider provider) {
    final isSelected = provider.filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setFilter(label),
      selectedColor: const Color(0xFF6A11CB).withAlpha(40),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6A11CB) : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6A11CB) : Colors.transparent,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFF6A11CB),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Add a new task to get started.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

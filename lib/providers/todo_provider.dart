import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String _filter = 'All'; // 'All', 'Active', 'Completed'
  String _categoryFilter = 'All'; // 'All', 'Work', 'Personal', etc.

  List<Todo> get todos {
    List<Todo> filtered = _todos;

    if (_filter == 'Active') {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    } else if (_filter == 'Completed') {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    }

    if (_categoryFilter != 'All') {
      filtered = filtered.where((todo) => todo.category == _categoryFilter).toList();
    }

    // Sort by due date, nulls last
    filtered.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return filtered;
  }

  String get filter => _filter;
  String get categoryFilter => _categoryFilter;

  TodoProvider() {
    _loadTodos();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      final List<dynamic> decodedList = json.decode(todosString);
      _todos = decodedList.map((item) => Todo.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_todos.map((t) => t.toMap()).toList());
    await prefs.setString('todos', encodedList);
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void editTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _saveTodos();
    notifyListeners();
  }

  void toggleCompletion(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _saveTodos();
      notifyListeners();
    }
  }
}

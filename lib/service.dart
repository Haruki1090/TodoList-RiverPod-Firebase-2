import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist_riverpod_firebase2/todo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create
  Future<void> addTodo(Todo todo) async {
    try {
      // Collection名　-> todoList
      // ID -> createdAtを文字列変換したもの
      await _db.collection('todoList').doc(todo.createdAt.toString()).set({
        'title': todo.title,
        'isDone': todo.isDone,
        'createdAt': todo.createdAt,
      });
    } catch (e) {
      print('Error adding todo: $e');
      throw e;
    }
  }

  /// Read
  Stream<List<Todo>> readTodo() {
    try {
      // Collection名 -> todoList
      return _db.collection('todoList').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Todo(
            title: data['title'],
            isDone: data['isDone'],
            createdAt: data['createdAt'].toDate(),
          );
        }).toList();
      });
    } catch (e) {
      print('Error reading todo: $e');
      throw e;
    }
  }

  /// Update
  Future<void> updateTodo(Todo todo) async {
    try {
      // Collection名 -> todoList
      // ID -> createdAtを文字列変換したもの
      await _db.collection('todoList').doc(todo.createdAt.toString()).update({
        'title': todo.title,
        'isDone': todo.isDone,
      });
    } catch (e) {
      print('Error updating todo: $e');
      throw e;
    }
  }

  /// Delete
  Future<void> deleteTodo(Todo todo) async {
    try {
      // Collection名 -> todoList
      // ID -> createdAtを文字列変換したもの
      await _db.collection('todoList').doc(todo.createdAt.toString()).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      throw e;
    }
  }
}

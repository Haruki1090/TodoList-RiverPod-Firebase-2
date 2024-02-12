import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist_riverpod_firebase2/todo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create
  Future<void> addTodo(Todo todo) async {
    try {
      // Collection名　-> todoList
      // ID -> documentReference.id
      final documentReference = _db.collection('todoList').doc();
      await documentReference.set({
        'id': documentReference.id,
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
  Stream<List<Todo>> getTodoList() {
    try {
      // Collection名 -> todoList
      return _db.collection('todoList').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Todo(
            id: doc.id, // Change this line
            title: doc['title'],
            isDone: doc['isDone'],
            createdAt: doc['createdAt'].toDate(),
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting todoList: $e');
      throw e;
    }
  }

  /// Update
  Future<void> updateTodo(Todo todo) async {
    try {
      // Collection名 -> todoList
      // ID -> createdAtを文字列変換したもの
      var document = _db.collection('todoList').doc(todo.id);

      var docSnapshot = await document.get();
      if (docSnapshot.exists) {
        // ドキュメントが存在する場合
        await document.update({
          'title': todo.title,
          'isDone': todo.isDone,
        });
      } else {
        // ドキュメントが存在しない場合
        print('Document does not exist for Todo: $todo');
      }
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
      await _db.collection('todoList').doc(todo.id).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      throw e;
    }
  }
}
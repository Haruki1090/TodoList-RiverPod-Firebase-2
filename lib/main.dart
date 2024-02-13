import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_riverpod_firebase2/todo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      home: TodoScreen(),
    );
  }
}

final _todoListProvider = StateProvider<List<Todo>>((ref) => <Todo>[]);

class TodoScreen extends ConsumerWidget {
  TextEditingController _textController = TextEditingController();
  final _firestoreService = FirestoreService();

  late final Todo newTodo;
  late BuildContext _context;

  TodoScreen() : super() {
    newTodo = Todo(
      id: '',
      title: '',
      isDone: false,
      createdAt: DateTime.now(),
    );
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: _context,
      builder: (context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(context, ref) {
    _context = context;
    List<Todo> _todoList = ref.watch(_todoListProvider);

    void _readTodo() async {
      try {
        var todoList = await _firestoreService.getTodoList().first;
        ref.read(_todoListProvider.notifier).state = todoList;
      } catch (e) {
        _showErrorDialog('Todoの読み込みに失敗しました: $e');
      }
    }

    void _addTodo() async {
      String newTodoTitle = _textController.text;
      if (newTodoTitle.isNotEmpty) {
        var newTodo = Todo(
          id: '',
          title: newTodoTitle,
          isDone: false,
          createdAt: DateTime.now(),
        );
        try {
          await _firestoreService.addTodo(newTodo);

          /// データを追加した後にFirestoreから最新のデータを読み込む
          _readTodo();

          _textController.clear();
        } catch (e) {
          _showErrorDialog('Todoの追加に失敗しました: $e');
        }
      }
    }

    void _editTodo(int index) async {
      var updatedTodoList = List<Todo>.from(_todoList);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('編集'),
            content: TextField(
              controller: TextEditingController(text: _todoList[index].title),
              onChanged: (value) {
                var updatedTodo = _todoList[index].copyWith(title: value);
                updatedTodoList[index] = updatedTodo;
              },
            ),
            actions: [
              TextButton(
                child: Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('保存'),
                onPressed: () async {
                  try {
                    // Firestore への更新
                    await _firestoreService.updateTodo(updatedTodoList[index]);

                    // リストの更新
                    ref.read(_todoListProvider.notifier).state = updatedTodoList;
                    Navigator.pop(context);
                  } catch (e) {
                    _showErrorDialog('Todoの更新に失敗しました: $e');
                  }
                },
              ),
            ],
          );
        },
      );
    }

    void _deleteTodo(int index) async {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text('削除確認'),
          content: Text('削除してもよろしいですか？'),
          actions: [
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('削除'),
              onPressed: () async {
                try {
                  // Firestore から削除
                  await _firestoreService.deleteTodo(_todoList[index]);
                  // リストの更新
                  var updatedTodoList = List<Todo>.from(_todoList);
                  updatedTodoList.removeAt(index);
                  ref.read(_todoListProvider.notifier).state = updatedTodoList;

                  Navigator.pop(context);
                } catch (e) {
                  _showErrorDialog('Todoの削除に失敗しました: $e');
                }
              },
            ),
          ],
        );
      });
    }


    void _toggleDone(int index, bool value) async {
      var updatedTodo = _todoList[index].copyWith(isDone: value);
      var updatedTodoList = List<Todo>.from(_todoList);
      updatedTodoList[index] = updatedTodo;

      try {
        await _firestoreService.updateTodo(updatedTodo);
        ref.read(_todoListProvider.notifier).state = updatedTodoList;
      } catch (e) {
        _showErrorDialog('Todoの更新に失敗しました: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
                _readTodo();
              },
              icon: Icon(Icons.refresh))
        ],
        title: Text('Todo App'),
      ),
      body: Column(
        children: [
          // 入力欄
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Todoを入力してください',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addTodo(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(_todoList[index].title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _todoList[index].isDone,
                          onChanged: (value) {
                            _toggleDone(index, value!);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTodo(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTodo(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
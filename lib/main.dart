import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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

class Todo {
  String title;
  bool isDone;
  DateTime dateTime;

    Todo(this.title, this.isDone, this.dateTime);
}

class TodoScreen extends ConsumerWidget {
  TextEditingController _textController = TextEditingController();
  final _todoListProvider = StateProvider<List<Todo>>((ref) => <Todo>[]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Todo> _todoList = ref.watch(_todoListProvider);

    void _addTodo(ref, context) {
      String newTodoTitle = _textController.text;
      if (newTodoTitle.isNotEmpty) {
        var newTodo = Todo(
          newTodoTitle,
          false,
          DateTime.now(),
        );
        ref.read(_todoListProvider.notifier).state = [..._todoList, newTodo];
        _textController.clear();
      }
    }

    void _editTodo(int index, WidgetRef ref, BuildContext context) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text('編集'),
          content: TextField(
            controller: TextEditingController(text: _todoList[index].title),
            onChanged: (value) {
              var updatedTodoList = List<Todo>.from(_todoList);
              updatedTodoList[index].title = value;
              ref.read(_todoListProvider.notifier).state = updatedTodoList;
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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    }

    void _deleteTodo(int index, WidgetRef ref, BuildContext context) {
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
              onPressed: () {
                var updatedTodoList = List<Todo>.from(_todoList);
                updatedTodoList.removeAt(index);
                ref.read(_todoListProvider.notifier).state = updatedTodoList;
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    }

    void _toggleDone(int index, bool value, WidgetRef ref, BuildContext context) {
      List<Todo> updatedTodoList = List<Todo>.from(_todoList);
      updatedTodoList[index].isDone = value;
      ref.read(_todoListProvider.notifier).state = updatedTodoList;
    }


    return Scaffold(
      appBar: AppBar(
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
                      onPressed: () => _addTodo(ref, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Todoリスト
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
                            _toggleDone(index, value!, ref, context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTodo(index, ref, context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTodo(index, ref, context);
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

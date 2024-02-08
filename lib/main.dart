import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class Todo {
  String text;
  bool isDone;

  Todo(this.text, this.isDone);
}

class _TodoScreenState extends State<TodoScreen> {
  TextEditingController _textController = TextEditingController();
  List<Todo> _todoList = [];

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        _addTodo();
                      },
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
                    title: Text(_todoList[index].text),
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

  void _addTodo() {
    setState(() {
      String text = _textController.text;
      if (text.isNotEmpty) {
        _todoList.add(Todo(text, false));
        _textController.clear();
      }
    });
  }

  void _editTodo(int index) {
     showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text('編集'),
          content: TextField(
            controller: TextEditingController(text: _todoList[index].text),
            onChanged: (value) {
              _todoList[index].text = value;
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
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      });
  }

  void _deleteTodo(int index) {
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
              setState(() {
                _todoList.removeAt(index);
                Navigator.pop(context);
              });
            },
          ),
        ],
      );
    });
  }

  void _toggleDone(int index, bool value) {
    setState(() {
      _todoList[index].isDone = value;
    });
  }
}

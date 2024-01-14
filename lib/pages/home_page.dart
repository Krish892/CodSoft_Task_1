import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../widgets/to_do_item.dart';

import '../model/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final todoList = ToDo.todoList();
  final _todoController = TextEditingController();
  List<ToDo> _foundTodoList = [];

  Container _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 31, 32),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        onChanged: (value) => runFilter(value),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white70,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFEEEFF5),
      elevation: 0,
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Text(
            'ToDo',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          Spacer(),
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://thumbs.dreamstime.com/b/logo-avengers-145259952.jpg'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _foundTodoList = todoList;
    super.initState();
  }

  void selectHandler(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void deleteTodoItem(String id) {
    setState(() {
      todoList.removeWhere((todo) => todo.id == id);
    });
  }

  void addNewItem(ToDo todoo) {
    final url = Uri.parse(
        'https://todo-app-34145-default-rtdb.firebaseio.com/todo.json');
    http.post(
      url,
      body: json.encode(
        {
          'id': todoo.id,
          'todoText': todoo.todoText,
        },
      ),
    );

    setState(
      () {
        if (_todoController.text.isNotEmpty) {
          todoList.insert(
            0,
            ToDo(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              todoText: _todoController.text,
            ),
          );
        } else {
          return;
        }
      },
    );
    _todoController.clear();
  }

  void runFilter(String enteredKeyword) {
    List<ToDo> result = [];
    if (enteredKeyword.isEmpty) {
      result = todoList;
    } else {
      result = todoList
          .where(
            (item) => item.todoText.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
          )
          .toList();
    }

    setState(() {
      _foundTodoList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 31, 31, 32),
      // appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: _searchBox()),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Text(
                'All ToDos',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: todoList.isEmpty
                    ? const Center(
                        child: Text(
                          'Add new ToDo item to your list !',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          for (ToDo todoo in _foundTodoList)
                            ToDoItem(
                              todo: todoo,
                              selectHandler: () => selectHandler(todoo),
                              onDeleteItem: () => deleteTodoItem(todoo.id),
                            ),
                        ],
                      ),
              ),
            ),

            // TextField and add button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 31, 31, 32),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _todoController,
                        onSubmitted: (_) {
                          if (_todoController.text.isEmpty) {
                            return;
                          } else {
                            addNewItem(
                              ToDo(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                todoText: _todoController.text,
                              ),
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Add new ToDo item to your list',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      if (_todoController.text.isEmpty) {
                        return;
                      } else {
                        addNewItem(
                          ToDo(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            todoText: _todoController.text,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 31, 31, 32),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

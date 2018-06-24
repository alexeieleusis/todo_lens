import 'package:meta/meta.dart';
import 'package:todo_lens/src/domain/lens_case.dart';

@immutable
class Todo {
  final String description;
  final bool done;

  const Todo(this.description, {this.done = false});

  Todo copy({String description, bool done}) =>
      new Todo(description ?? this.description, done: done ?? this.done);

  @override
  String toString() => 'Todo{description: $description, done: $done}';
}

class TodosStore {
  final LensCase<Iterable<Todo>> lens = new LensCase.of(<Todo>[]);

  TodosStore();

  void addTodo(String description) {
    lens.evolve((todos) {
      final newTodos = todos.toList()..add(new Todo(description));
      return newTodos;
    });
  }

  void removeTodo(int index) {
    lens.evolve((todos) {
      final list = todos.toList()..removeAt(index);
      return list;
    });
  }

  void toggle(int index) {
    lensAt(index).evolve((todo) => todo.copy(done: !todo.done));
  }

  LensCase<Todo> lensAt(int index) => lens.getSight(
          (todos) => index < todos.length ? todos.elementAt(index) : null,
          (newTodo, todos) {
        final list = todos.toList();
        list[index] = newTodo;
        return list;
      });
}

class TodoStore {
  final LensCase<Todo> lens;

  TodoStore(this.lens);

  void changeDescription(String description) {
    lens.evolve((todo) => todo.copy(description: description));
  }

  void delete() {
    changeDescription('');
  }

  void toggle() {
    lens.evolve((todo) => todo.copy(done: !todo.done));
  }
}

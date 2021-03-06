import 'package:meta/meta.dart';
import 'package:shuttlecock/shuttlecock.dart';

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
  final LensCase<IterableMonad<Todo>> lens =
      new LensCase.of(new IterableMonad<Todo>());

  TodosStore();

  void addTodo(String description) {
    print('addTodo($description)');
    lens.evolve((todos) {
      final newTodos = todos.toList()..add(new Todo(description));
      print('evolving $newTodos');
      return new IterableMonad.fromIterable(newTodos);
    });
  }

  void removeTodo(int index) {
    lens.evolve((todos) {
      final list = todos.toList()..removeAt(index);
      return new IterableMonad.fromIterable(list);
    });
  }

  void toggle(int index) {
    lensAt(index).evolve((todo) => todo.copy(done: !todo.done));
  }

  LensCase<Todo> lensAt(int index) =>
      lens.getSight((todos) => todos.elementAt(index), (newTodo, todos) {
        final list = todos.toList();
        list[index] = newTodo;
        return new IterableMonad.fromIterable(list);
      });
}

class TodoStore {
  final LensCase<Todo> lens;

  TodoStore(this.lens);

  void changeDescription(String description) {
    lens.evolve((todo) => todo.copy(description: description));
  }

  void delete() {
    print('TodoStore.deleteTodo');
    changeDescription('');
  }

  void toggle() {
    print('toggle');
    lens.evolve((todo) => todo.copy(done: !todo.done));
  }
}

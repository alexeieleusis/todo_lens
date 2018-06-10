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
  Iterable<LensCase<Todo>> _childLenses = [];
  final LensCase<IterableMonad<Todo>> lens =
      new LensCase.of(new IterableMonad<Todo>());

  TodosStore() {
    lens.stream.listen((_) {
      lens
          .getSightSequence(identity, (pieces, whole) => pieces)
          .first
          .then((lenses) {
        _childLenses = lenses;
      });
    });
  }

  Iterable<LensCase<Todo>> get childLenses => _childLenses;

  void addTodo(String description) {
    print('addTodo($description})');
    lens.evolve((todos) {
      final newTodos = todos.toList()..add(new Todo(description));
      print('evolving $newTodos');
      return new IterableMonad.fromIterable(newTodos);
    });
  }

  void removeTodo(Todo todo) {
    lens.evolve((todos) =>
        new IterableMonad.fromIterable(todos.where((t) => t != todo)));
  }
}

class TodoStore {
  final LensCase<Todo> lens;

  TodoStore(this.lens);

  void changeDescription(String description) {
    lens.evolve((todo) => todo.copy(description: description));
  }

  void deleteTodo() {
    print('TodoStore.deleteTodo');
    changeDescription('');
  }

  void toggle() {
    print('toggle');
    lens.evolve((todo) => todo.copy(done: !todo.done));
  }
}

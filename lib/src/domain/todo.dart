import 'package:meta/meta.dart';
import 'package:todo_lens/src/domain/lens_case.dart';

@immutable
class Attachment {
  final String name;
  final int views;
  final Todo owner;

  const Attachment(this.name, this.owner, {this.views = 0});

  Attachment copy({String name, int views}) =>
      new Attachment(name ?? this.name, owner, views: views ?? this.views);

  @override
  String toString() => 'Attachment{name: $name, views: $views}';
}

class Todo {
  static int _counter = 1;
  final String description;
  final bool done;
  Iterable<Attachment> _attachments;

  Todo(this.description, {this.done = false}) {
    _attachments = [
      new Attachment('${_counter++}', this),
      new Attachment('${_counter++}', this),
      new Attachment('${_counter++}', this),
      new Attachment('${_counter++}', this)
    ];
  }

  Todo._(this.description, this._attachments, {this.done = false});

  Iterable<Attachment> get attachments => _attachments;

  Todo copy(
          {String description, Iterable<Attachment> attachments, bool done}) =>
      new Todo._(
          description ?? this.description, attachments ?? this.attachments,
          done: done ?? this.done);

  @override
  String toString() => 'Todo{description: $description, done: $done,'
      ' attachments: $_attachments}';
}

class TodosStore {
  final LensCase<Iterable<Todo>> lens = new LensCase.of(<Todo>[]);

  TodosStore();

  void addTodo(String description) {
    lens.evolve((todos) => todos.toList()..add(new Todo(description)));
  }

  LensCase<Todo> todoLensAt(int index) => lens.getSight(
          (todos) => index < todos.length ? todos.elementAt(index) : null,
          (newTodo, todos) {
        final list = todos.toList();
        list[index] = newTodo;
        return list;
      });

  LensCase<Iterable<Attachment>> get attachmentsLenses => lens.getSight(
      (todos) => todos.expand((todo) => todo.attachments),
      (attachments, todos) => todos.map((todo) =>
          todo.copy(attachments: attachments.where((a) => a.owner == todo))));

  void removeTodo(int index) {
    lens.evolve((todos) => todos.toList()..removeAt(index));
  }

  void toggle(int index) {
    todoLensAt(index).evolve((todo) => todo.copy(done: !todo.done));
  }
}

class AttachmentStore {
  final LensCase<Attachment> lens;

  AttachmentStore(this.lens);

  void incrementViews() {
    lens.evolve((attachment) => attachment.copy(views: attachment.views + 1));
  }
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

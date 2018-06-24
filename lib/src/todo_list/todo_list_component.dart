import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:todo_lens/src/domain/todo.dart';
import 'package:todo_lens/src/todo_list/todo_component.dart';

@Component(
    selector: 'todo-list',
    styleUrls: ['todo_list_component.css'],
    templateUrl: 'todo_list_component.html',
    directives: [
      MaterialCheckboxComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      materialInputDirectives,
      NgFor,
      NgIf,
      TodoComponent
    ],
    changeDetection: ChangeDetectionStrategy.Stateful)
class TodoListComponent extends ComponentState {
  final TodosStore _store = new TodosStore();
  String newTodo = '';
  final List<TodoStore> _stores = [];

  TodoListComponent() {
    _store.lens.stream.listen((todos) {
      setState(() {
        final indices = new Iterable.generate(todos.length)
            .where((index) => !removeItem(todos.elementAt(index)));
        if (indices.length < todos.length) {
          _store.lens
              .update(indices.map((index) => todos.elementAt(index)).toList());
          return;
        }

        while (todos.length < _stores.length) {
          _stores.removeLast();
          return;
        }

        _stores.addAll(todos
            .skip(_stores.length)
            .toList()
            .asMap()
            .keys
            .map((index) => _stores.length + index)
            .toList()
            .map(_store.lensAt)
            .map((lens) => new TodoStore(lens)));
      });
    });
  }

  Iterable<TodoStore> get stores => _stores;

  void add(String description) {
    _store.addTodo(description);
    newTodo = '';
  }

  bool removeItem(Todo todo) => todo.description == '';
}

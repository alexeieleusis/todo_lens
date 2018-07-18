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
  Todo todo;
  int index;
  final List<TodoStore> _todosStores = [];
  final List<AttachmentStore> _attachmentsStores = [];

  TodoListComponent() {
    _store.lens.stream.listen((todos) {
      setState(() {
        final indices = new Iterable.generate(todos.length)
            .where((index) => !removeItem(todos.elementAt(index)));
        if (indices.length < todos.length) {
          _store.lens
              .update(indices.map((index) => todos.elementAt(index)).toList());
          _todosStores.removeRange(indices.length, _todosStores.length);
          return;
        }

        _todosStores.addAll(todos
            .skip(_todosStores.length)
            .toList()
            .asMap()
            .keys
            .map((index) => _todosStores.length + index)
            .toList()
            .map(_store.todoLensAt)
            .map((lens) => new TodoStore(lens)));

        todos.fold([], (lenses, todo) {

        });
      });
    });
  }

  Iterable<TodoStore> get stores => _todosStores;

  void add(String description) {
    if (todo == null) {
      _store.addTodo(description);
    } else {
      // This is just an example! Don't do this with prod code.
      _todosStores[index].changeDescription(newTodo);
      todo = null;
      index = null;
    }
    newTodo = '';
  }

  void edit(Todo todo, int index) {
    this.todo = todo;
    this.index = index;
    newTodo = todo.description;
  }

  bool removeItem(Todo todo) => todo.description == '';
}

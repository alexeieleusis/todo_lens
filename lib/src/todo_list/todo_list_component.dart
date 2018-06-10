import 'package:shuttlecock/shuttlecock.dart';
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
  providers: [],
  changeDetection: ChangeDetectionStrategy.Stateful
)
class TodoListComponent extends ComponentState {
  final TodosStore _store = new TodosStore();
  Iterable<TodoStore> _stores = [];
  String newTodo = '';

  TodoListComponent() {
    _store.lens.stream.listen((_) {
      print('new todos ${_.toList()}');
      _store.lens
          .getSightSequence(identity, (pieces, collection) => pieces)
          .last
          .then((lenses) {
        setState(() {
          print('creating new stores ${lenses.length}');
          _stores = lenses.map((l) => new TodoStore(l));
        });
      });
    });
  }

  Iterable<TodoStore> get items => _stores;

  void add() {
    _store.addTodo(newTodo);
    newTodo = '';
  }

  String remove(int index) => 'items.removeAt(index)';
}

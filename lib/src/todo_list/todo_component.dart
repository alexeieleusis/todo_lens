import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:todo_lens/src/domain/todo.dart';

@Component(
  selector: 'todo',
  styleUrls: ['todo_component.css'],
  templateUrl: 'todo_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
  changeDetection: ChangeDetectionStrategy.Stateful
)
class TodoComponent extends ComponentState {
  TodoStore _store;
  StreamSubscription<Todo> _subscription;
  Todo todo = const Todo('');

  @Input()
  // ignore: avoid_setters_without_getters
  set store(TodoStore value) {
    print('setting store on todo component ${value.hashCode}');
    _store = value;
    _subscription?.cancel();
    _subscription = _store.lens.stream.listen((t) {
      print('todo store emitted ${t.description}');
      setState(() {
        todo = t;
        print('todo updates ${todo.description}');
      });
    });
  }

  void remove() {
    print('TodoComponent.remove ${todo.description}');
    _store.deleteTodo();
  }

  void toggle() {
    print('TodoComponent.toggle ${todo.description}');
    _store.toggle();
  }
}

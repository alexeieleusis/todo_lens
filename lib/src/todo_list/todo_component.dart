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
    ])
class TodoComponent extends ComponentState implements OnDestroy {
  static int _counter = 0;
  final int tag;
  Todo _todo = const Todo('');
  StreamSubscription<Todo> _subscription;
  TodoStore _store;

  TodoComponent() : tag = _counter {
    _counter++;
  }

  TodoStore get store => _store;

  @Input()
  set store(TodoStore value) {
    if(store == value) {
      return;
    }

    _subscription?.cancel();
    _todo = new Todo('${value.hashCode}');
    _store = value;
    _subscription = _store.lens.stream.listen((t) {
      setState(() {
        _todo = t;
      });
    });
  }

  Todo get todo => _todo;

  @override
  void ngOnDestroy() {
    _subscription?.cancel();
  }

  void remove() {
    _store.delete();
  }

  void toggle() {
    _store.toggle();
  }
}

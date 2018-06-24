import 'package:test/test.dart';
import 'package:todo_lens/src/domain/todo.dart';

void main() {
  group('TodosStore', () {
    TodosStore store;

    setUp(() async {
      store = new TodosStore();
    });

    test('adds a todo', () async {
      final first = store.lens.stream.skip(1).first;

      store.addTodo('this is a todo');
      final result = await first;

      expect(result.length, 1);
      expect(result.first.description, 'this is a todo');
    });
  });

  // Testing info: https://webdev.dartlang.org/angular/guide/testing
}

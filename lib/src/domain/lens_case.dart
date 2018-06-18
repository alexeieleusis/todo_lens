import 'dart:async';

import 'package:rxdart/rxdart.dart';

// a -> a
typedef EndoFunction<A> = A Function(A a);




// (a -> a) -> ()
typedef Evolver<A> = void Function(EndoFunction<A> evolution);

// LensCase w
class LensCase<W> {
  // (w -> w) -> ()
  Evolver<W> _evolver;

  // Stream w
  Observable<W> _stream;

  /// Builds a new instance given an initial state.
  LensCase.of(W initialState) {
    W identity(W w) => w;
    final evolutions = new PublishSubject<EndoFunction<W>>();
    void evolver(EndoFunction<W> evolution) {
      evolutions.add(evolution);
    }

    _evolver = evolver;
    _stream = new BehaviorSubject<W>(seedValue: initialState)
      ..addStream(evolutions.stream.scan((state, action, _) => action(state), initialState));
  }

  /// Builds a new instance given a sink of evolutions and a stream of values.
  // Do we want to make this constructor private to ensure we always know the
  // stream repeats its last value and is broadcast?
  LensCase.on(Evolver<W> evolver, Observable<W> stream)
      : this._evolver = evolver,
        this._stream = stream;

  /// (a -> a) -> ()
  void evolve(EndoFunction<W> evolution) {
    _evolver(evolution);
  }

  /// a -> ()
  void update(W a) => _evolver((oldA) => a);

  /// (a -> b) -> (b -> a -> a) -> LensCase b
  LensCase<TPiece> getSight<TPiece>(
      TPiece getter(W whole), W setter(TPiece piece, W whole)) {
    // evolutions :: Stream (a -> a)
    // sink :: Stream (b -> b)
    void sinker(TPiece evolve(TPiece piece1)) {
      W newEvol(W whole) => setter(evolve(getter(whole)), whole);
      _evolver(newEvol);
    }

    return new LensCase.on(sinker, _stream.map(getter).distinct());
  }

//  StreamMonad<IterableMonad<LensCase<TPiece>>> getSightSequence<TPiece>(
//      Iterable<TPiece> getter(W whole),
//      W setter(Iterable<TPiece> pieces, W whole)) {
//    // TODO: Should there be an overload accepting events from new lenses as
//    // long as they are in the specified index?
//    var emitted = false;
//    final pieceLens = getSight(getter, setter);
//    final future = _stream.first.then((whole) {
//      final pieces = getter(whole).toList().asMap();
//      final lenses = pieces
//          .map((index, piece) => new MapEntry(index, new LensCase.of(piece)));
//      final subscriptions = lenses.map((index, lens) => new MapEntry(
//          index,
//          lens.stream.skip(1).listen((piece) {
//            final newPieces = pieces.values.toList();
//            newPieces[index] = piece;
//            if (!emitted) {
//              pieceLens.update(newPieces);
//            }
//            emitted = true;
//          })));
//      _stream.first.then((state) {
//        subscriptions.values.forEach((subscription) => subscription.cancel());
//      });
//      return new IterableMonad.fromIterable(lenses.values);
//    });
//    return new FutureMonad(future).asStream();
//  }

  /// view/get :: Stream a
  Stream<W> get stream => _stream;
}

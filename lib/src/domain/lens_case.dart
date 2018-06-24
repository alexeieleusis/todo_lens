import 'dart:async';

import 'package:rxdart/rxdart.dart';

// a -> a
typedef EndoFunction<A> = A Function(A a);

// (a -> a) -> ()
typedef Evolver<A> = void Function(EndoFunction<A> evolution);

class LensCase<U> {
  // (a -> a) -> ()
  Evolver<U> _evolver;

  // Stream a
  Observable<U> _stream;

  /// Builds a new instance given an initial state.
  LensCase.of(U initialState) {
    // TODO: Implement disposable and close the sink there.
    final evolutions = new PublishSubject<EndoFunction<U>>();
    void evolver(EndoFunction<U> evolution) {
      evolutions.add(evolution);
    }

    _evolver = evolver;
    _stream = new BehaviorSubject<U>(seedValue: initialState)
      ..addStream(evolutions.stream
          .scan((state, action, _) => action(state), initialState));
  }

  /// Builds a new instance given a sink of evolutions and a stream of values.
  // Do we want to make this constructor private to ensure we always know the
  // stream repeats its last value and is broadcast?
  LensCase.on(Evolver<U> evolver, Stream<U> stream)
      : this._evolver = evolver,
        this._stream = new Observable(stream);

  /// (a -> a) -> ()
  void evolve(EndoFunction<U> evolution) => _evolver(evolution);

  /// a -> ()
  void update(U newState) => _evolver((_) => newState);

  /// (a -> b) -> (b -> a -> a) -> LensCase b
  LensCase<P> getSight<P>(P getter(U whole), U setter(P piece, U whole)) {
    // evolutions :: Stream (a -> a)
    // sink :: Stream (b -> b)
    void sinker(P evolve(P piece)) {
      U newEvolution(U whole) => setter(evolve(getter(whole)), whole);
      _evolver(newEvolution);
    }

    return new LensCase.on(sinker, _stream.map(getter).distinct());
  }

  /// view/get :: Stream a
  Observable<U> get stream => _stream;
}

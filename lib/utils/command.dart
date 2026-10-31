// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);
typedef CommandSuccess<T> = void Function(T);

/// Encapsulates an action and exposes its running and result states.
///
/// Repeated executions share the same Future while running.
/// Actions must return a [Result]. Exceptions are propagated through
/// the Future returned by [execute].
///
/// Call [clearResult] after consuming the result.
abstract class Command<T> extends ChangeNotifier {
  Command();

  int _executionId = 0;
  Future<void>? _executionFuture;

  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get error => _result is Err;
  bool get success => _result is Ok;

  void clearResult() {
    if (_result == null) return;

    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action, {CommandSuccess<T>? onSuccess}) {
    final existing = _executionFuture;
    if (existing != null) return existing;

    final executionId = ++_executionId;
    final completer = Completer<void>();
    final future = completer.future;

    _executionFuture = future;
    _running = true;
    _result = null;
    notifyListeners();

    if (executionId != _executionId) {
      if (identical(_executionFuture, future)) {
        _executionFuture = null;
      }

      completer.complete();
      return future;
    }

    final execution = Future<void>.sync(() async {
      Result<T>? result;

      try {
        result = await action();
      } finally {
        if (executionId == _executionId) {
          _result = result;
          _running = false;

          try {
            if (result case Ok(:final value)) {
              onSuccess?.call(value);
            }
          } finally {
            notifyListeners();
          }
        }
      }
    });

    unawaited(
      execution.then<void>(
        (_) {
          if (identical(_executionFuture, future)) {
            _executionFuture = null;
          }
          completer.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_executionFuture, future)) {
            _executionFuture = null;
          }
          completer.completeError(error, stackTrace);
        },
      ),
    );

    return future;
  }

  void _cancel(VoidCallback onCancel) {
    if (!_running) return;

    ++_executionId;
    _running = false;
    _executionFuture = null;

    try {
      onCancel();
    } finally {
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  final CommandAction0<T> _action;
  final CommandSuccess<T>? _onSuccess;
  final VoidCallback? _onCancel;

  Command0(this._action, {this._onSuccess, this._onCancel});

  Future<void> execute() {
    return _execute(_action, onSuccess: _onSuccess);
  }

  void cancel() {
    if (_onCancel == null) {
      throw StateError('You should not call cancel without providing onCancel.');
    }

    if (!running) return;
    _cancel(_onCancel);
  }
}

class Command1<T, A> extends Command<T> {
  final CommandAction1<T, A> _action;
  final CommandSuccess<T>? _onSuccess;
  final VoidCallback? _onCancel;

  Command1(this._action, {this._onSuccess, this._onCancel});

  Future<void> execute(A argument) {
    return _execute(
      () => _action(argument),
      onSuccess: _onSuccess,
    );
  }

  void cancel() {
    if (_onCancel == null) {
      throw StateError('You should not call cancel without providing onCancel.');
    }

    if (!running) return;
    _cancel(_onCancel);
  }
}

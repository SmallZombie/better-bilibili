// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);
typedef CommandAction2<T, A, B> = Future<Result<T>> Function(A, B);
typedef CommandSuccess<T> = void Function(T);

/// Facilitates interaction with a ViewModel.
///
/// Encapsulates an action,
/// exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
///
/// Use [Command0] for actions without arguments.
/// Use [Command1] for actions with one argument.
/// Use [CancellableCommand0] / [CancellableCommand1] when the caller needs
/// to abort an in-flight action.
///
/// Actions must return a [Result].
///
/// Consume the action result by listening to changes,
/// then call to [clearResult] when the state is consumed.
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;

  /// True when the action is running.
  bool get running => _running;

  Result<T>? _result;

  /// true if action completed with error
  bool get error => _result is Error;

  /// true if action completed successfully
  bool get completed => _result is Ok;

  /// Get last action result
  Result? get result => _result;

  int _execSeq = 0;

  /// Clear last action result
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Internal execute implementation
  Future<void> _execute(CommandAction0<T> action, {CommandSuccess<T>? onSuccess}) async {
    // Ensure the action can't launch multiple times.
    // e.g. avoid multiple taps on button
    if (_running) return;

    final seq = ++_execSeq;

    // Notify listeners.
    // e.g. button shows loading state
    _running = true;
    _result = null;
    notifyListeners();

    Result<T>? r;
    try {
      r = await action();
    } finally {
      if (seq == _execSeq) {
        _result = r;
        _running = false;
        if (r case Ok(:final value)) {
          onSuccess?.call(value);
        }
        notifyListeners();
      }
    }
  }
}

/// [Command] without arguments.
/// Takes a [CommandAction0] as action.
class Command0<T> extends Command<T> {
  Command0(this._action, {CommandSuccess<T>? onSuccess}) : _onSuccess = onSuccess;

  final CommandAction0<T> _action;
  final CommandSuccess<T>? _onSuccess;

  /// Executes the action.
  Future<void> execute() async {
    await _execute(_action, onSuccess: _onSuccess);
  }
}

/// [Command] with one argument.
/// Takes a [CommandAction1] as action.
class Command1<T, A> extends Command<T> {
  Command1(this._action, {CommandSuccess<T>? onSuccess}) : _onSuccess = onSuccess;

  final CommandAction1<T, A> _action;
  final CommandSuccess<T>? _onSuccess;

  /// Executes the action with the argument.
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument), onSuccess: _onSuccess);
  }
}

/// [Command] with two argument.
/// Takes a [CommandAction1] as action.
class Command2<T, A, B> extends Command<T> {
  Command2(this._action, {CommandSuccess<T>? onSuccess}) : _onSuccess = onSuccess;

  final CommandAction2<T, A, B> _action;
  final CommandSuccess<T>? _onSuccess;

  /// Executes the action with the argument.
  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2), onSuccess: _onSuccess);
  }
}

/// 可取消的 [Command0]
class CancellableCommand0<T> extends Command0<T> {
  CancellableCommand0(
    CommandAction0<T> action, {
    CommandSuccess<T>? onSuccess,
    required VoidCallback onCancel,
  }) : _onCancel = onCancel,
       super(action, onSuccess: onSuccess);

  final VoidCallback _onCancel;

  /// 取消当前执行，
  /// 未在 running 时调用是安全的（no-op）
  void cancel() {
    if (!_running) return;
    _execSeq++;
    _running = false;
    notifyListeners();
    _onCancel();
  }
}

/// 可取消版的 [Command1]，
/// 语义同 [CancellableCommand0]
class CancellableCommand1<T, A> extends Command1<T, A> {
  CancellableCommand1(
    CommandAction1<T, A> action, {
    CommandSuccess<T>? onSuccess,
    required VoidCallback onCancel,
  }) : _onCancel = onCancel,
       super(action, onSuccess: onSuccess);

  final VoidCallback _onCancel;

  /// 取消当前执行，
  /// 未在 running 时调用是安全的（no-op）
  void cancel() {
    if (!_running) return;
    _execSeq++;
    _running = false;
    notifyListeners();
    _onCancel();
  }
}

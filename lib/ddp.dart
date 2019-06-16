library ddp;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tuple/tuple.dart';

part 'ddp_client.dart';
part 'ddp_collection.dart';
part 'ddp_ejson.dart';
part 'ddp_messages.dart';
part 'ddp_stats.dart';

class _IdManager {
  int _next;

  _IdManager() {
    this._next = 0;
  }

  String next() {
    final next = this._next;
    this._next++;
    return next.toRadixString(16);
  }
}

class _PingTracker {
  Function(Error) _handler;
  Duration _timeout;
  Timer _timer;
}

typedef void OnCallDone(Call call);

class Call {
  String id;
  String serviceMethod;
  dynamic args;
  dynamic reply;
  Error error;
  DdpClient owner;

  List<OnCallDone> _handlers = [];

  void onceDone(OnCallDone fn) {
    this._handlers.add(fn);
  }

  void done() {
    this.owner._calls.remove(this.id);
    this._handlers.forEach((h) => h(this));
    this._handlers = [];
  }
}

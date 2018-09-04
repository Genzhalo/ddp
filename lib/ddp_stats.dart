part of ddp;

enum LoggingDataType {
  DataByte,
  DataText,
}

//
class ReaderProxy extends Stream<dynamic> {
  Stream<dynamic> _reader;

  ReaderProxy(this._reader);

  @override
  Future<bool> any(bool test(element)) => this.any(test);

  @override
  StreamSubscription listen(
    void Function(dynamic event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return this._reader.listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  void setReader(Stream<dynamic> reader) => this._reader = reader;
}

class WriterProxy implements StreamSink<dynamic> {
  StreamSink<dynamic> _writer;

  WriterProxy(this._writer);

  @override
  void add(event) => this._writer.add(event);

  @override
  void addError(Object error, [StackTrace stackTrace]) =>
      this._writer.addError(error, stackTrace);

  @override
  Future addStream(Stream stream) => this._writer.addStream(stream);

  @override
  Future close() => this._writer.close();

  @override
  Future get done => this._writer.done;

  void setWriter(StreamSink<dynamic> writer) => this._writer = writer;
}

class LoggerMixin {
  bool active;
  int truncate;
  LoggingDataType _dtype;

  log(List<int> p, int n) {
    if (this.active) {
      int limit = n;
      bool trancated = false;
      if (this.truncate > 0 && this.truncate < limit) {
        limit = this.truncate;
        trancated = true;
      }
      switch (this._dtype) {
        case LoggingDataType.DataText:
          if (trancated) {
            print('[${n}] ${utf8.decode(p.sublist(0, limit))}...');
          } else {
            print('[${n}] ${utf8.decode(p.sublist(0, limit))}');
          }
          break;
        case LoggingDataType.DataByte:
        default:
          print(sprintf('%x', p.sublist(0, limit)));
      }
    }
    return n;
  }
}

class ReaderLogger extends ReaderProxy with LoggerMixin {
  ReaderLogger(Stream reader) : super(reader);
}

class WriterLogger extends WriterProxy with LoggerMixin {
  WriterLogger(StreamSink writer) : super(writer);
}

class Stats {
  int bytes;
  int ops;
  int errors;
  Duration runtime;
}

class ClientStats {
  Stats reads;
  Stats totalReads;
  Stats writes;
  Stats totalWrites;
  int reconnects;
  int pingsSent;
  int pingsRecv;
}

class CollectionStats {
  String name;
  int count;
}

class StatsTrackerMixin {
  int _bytes;
  int _ops;
  int _errors;
  DateTime _start;
  Mutex _lock;

  int op(int n) {
    this._lock.acquire();

    this._ops++;
    this._bytes += n;

    this._lock.release();
    return n;
  }

  Stats snapshot() => this._snap();

  Stats reset() {
    final stats = this._snap();
    this._bytes = 0;
    this._ops = 0;
    this._errors = 0;
    this._start = DateTime.now();
    return stats;
  }

  Stats _snap() {
    return Stats()
      ..bytes = this._bytes
      ..ops = this._ops
      ..errors = this._errors
      ..runtime = DateTime.now().difference(this._start);
  }
}

class ReaderStats extends ReaderProxy with StatsTrackerMixin {
  ReaderStats(Stream reader) : super(reader);
}

class WriterStats extends WriterProxy with StatsTrackerMixin {
  WriterStats(StreamSink writer) : super(writer);
}

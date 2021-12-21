import 'dart:io';
import 'dart:math';

import 'package:xid/src/base32codec.dart';
import 'package:xid/src/errors.dart';

const String _allChars = "0123456789abcdefghijklmnopqrstuv";

class Xid {
  static String? _machineId;
  static int? _counterInt;

  List<int>? _xidBytes;

  Xid() {
    _generateXid();
  }

  Xid.fromString(String newXid) {
    if (!_isValid(newXid)) {
      throw InvalidXidException();
    }
    _xidBytes = _toBytes(newXid);
  }

  String _toHexString() {
    return base32encode(_xidBytes!);
  }

  List<int> _toBytes(String xid) {
    return base32decode(xid);
  }

  static Xid get() {
    return Xid();
  }

  static String string() {
    return get().toString();
  }

  bool _isValid(String xid) {
    if (xid.length != 20) {
      return false;
    }

    var allowedChars = _allChars.split('');

    for (int i = 0; i < xid.length; i++) {
      var c = xid[i];
      if (allowedChars.contains(c)) {
        continue;
      }

      return false;
    }

    return true;
  }

  List<int> _getMachineId() {
    var machineId = _machineId;
    if (machineId != null) {
      return _toBytes(machineId);
    }

    machineId = Random.secure().nextInt(5170000).toString();
    _machineId = machineId;
    return _toBytes(machineId);
  }

  static int _counter() {
    _counterInt ??= Random.secure().nextInt(16777215);
    _counterInt = _counterInt! + 1;

    return _counterInt!;
  }

  String _generateXid() {
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var counter = _counter();
    var machineID = _getMachineId();

    _xidBytes = List.filled(20, 0, growable: false);

    _xidBytes![0] = (now >> 24) & 0xff;
    _xidBytes![1] = (now >> 16) & 0xff;
    _xidBytes![2] = (now >> 8) & 0xff;
    _xidBytes![3] = (now) & 0xff;

    _xidBytes![4] = machineID[0];
    _xidBytes![5] = machineID[1];
    _xidBytes![6] = machineID[2];

    _xidBytes![7] = (pid >> 8) & 0xff;
    _xidBytes![8] = (pid) & 0xff;

    _xidBytes![9] = (counter >> 16) & 0xff;
    _xidBytes![10] = (counter >> 8) & 0xff;
    _xidBytes![11] = (counter) & 0xff;

    return _toHexString();
  }

  @override
  String toString() {
    return _toHexString().toLowerCase().substring(0, 20);
  }

  List<int> toBytes() {
    return [...?_xidBytes];
  }
}

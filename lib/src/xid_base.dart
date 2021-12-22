import 'dart:io';
import 'dart:math';

import 'package:xid/src/base32codec.dart';
import 'package:xid/src/errors.dart';

const String _allChars = "0123456789abcdefghijklmnopqrstuv";

///
/// A globally unique identifier for objects.
///
/// <p>Consists of 12 bytes, divided as follows:</p>
///  <table border="1">
///   <caption>layout</caption>
///   <tr><td>0</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td></tr>
///   <tr><td colspan="4">time</td><td colspan="5">random value</td><td colspan="3">inc</td></tr>
/// </table>
///
///  Instances of this class are immutable.
///
class Xid {
  static String? _machineId;
  static int? _counterInt;

  List<int>? _xidBytes;

  /// Creates a new instance of xid
  Xid() {
    _generateXid();
  }

  ///
  /// Constructs a new instance of xid from the given a string of xid
  /// throws InvalidXidException if the string supplied is not a valid xid
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

  /// Creates and returns a new instance of xid
  static Xid get() {
    return Xid();
  }

  /// Creates a new instance of xid and returns the string representation
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

  /// Returns the byte representation of the current xid instance
  List<int> toBytes() {
    return [...?_xidBytes];
  }
}

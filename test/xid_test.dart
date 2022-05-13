import 'dart:collection';

import 'package:test/test.dart';
import 'package:xid/src/base32codec.dart';
import 'package:xid/xid.dart';

void main() {
  group('Assert xid is created correctly ', () {
    final List<int> idBytes = [
      0x4d,
      0x88,
      0xe1,
      0x5b,
      0x60,
      0xf4,
      0x86,
      0xe4,
      0x28,
      0x41,
      0x2d,
      0xc9
    ];
    final idString = "9m4e2mr0ui3e8a215n4g";
    test('Encoding works well', () {
      expect(base32encode(idBytes), idString.toUpperCase());
      expect(Xid.fromString(idString).toBytes(), idBytes);
      expect(Xid.fromString(base32encode(idBytes).toLowerCase()).toBytes(),
          idBytes);
    });

    final List<int> decodeIdBytes = [
      0x4d,
      0x88,
      0xe1,
      0x5b,
      0x60,
      0xf4,
      0x86,
      0xe4,
      0x28,
      0x41,
      0x2d,
      0xc9
    ];
    final decodeIdString = "9m4e2mr0ui3e8a215n4g";

    test('Decoding works well', () {
      expect(base32decode(decodeIdString), decodeIdBytes);
      expect(Xid.fromString(decodeIdString).toBytes(), decodeIdBytes);
      expect(Xid.fromString(decodeIdString).toString(), decodeIdString);
    });

    final xid = Xid();
    final xidStr = xid.toString();

    test('Xid is constant', () {
      expect(
        xidStr,
        xid.toString(),
      );
    });

    final reXid = Xid.fromString(xidStr);

    test('Xid test for re creation', () {
      expect(
        xidStr,
        reXid.toString(),
      );
    });

    test('Xid test for collisions', () {
      expect(
        hasNoCollisions(1000000),
        true,
      );
    });
  });
}

bool hasNoCollisions(int iterations) {
  Map<String, String> ids = HashMap();
  for (int i = 0; i < iterations; i++) {
    String id = Xid.string();
    if (ids.containsKey(id)) {
      return false;
    } else {
      ids[id] = id;
    }
  }
  return true;
}

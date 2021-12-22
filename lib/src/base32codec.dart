import "dart:typed_data";

const String _base32Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUV";

String base32encode(List<int> input) {
  Uint8List bytes = input is Uint8List ? input : Uint8List.fromList(input);
  int i = 0, index = 0, digit = 0;
  int currByte, nextByte;
  StringBuffer base32 = StringBuffer();

  while (i < bytes.length) {
    currByte = (bytes[i] >= 0) ? bytes[i] : (bytes[i] + 256);

    if (index > 3) {
      if ((i + 1) < bytes.length) {
        nextByte = (bytes[i + 1] >= 0) ? bytes[i + 1] : (bytes[i + 1] + 256);
      } else {
        nextByte = 0;
      }

      digit = currByte & (0xFF >> index);
      index = (index + 5) % 8;
      digit <<= index;
      digit |= nextByte >> (8 - index);
      i++;
    } else {
      digit = (currByte >> (8 - (index + 5)) & 0x1F);
      index = (index + 5) % 8;
      if (index == 0) {
        i++;
      }
    }
    base32.write(_base32Chars[digit]);
  }
  return base32.toString();
}

const List<int> _base32Lookup = [
  0x00,
  0x01,
  0x02,
  0x03,
  0x04,
  0x05,
  0x06,
  0x07,
  // '0', '1', '2', '3', '4', '5', '6', '7'
  0x08,
  0x09,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '8', '9', ':', ';', '<', '=', '>', '?'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
  0xFF,
  0x0A,
  0x0B,
  0x0C,
  0x0D,
  0x0E,
  0x0F,
  0x10,
  // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
  0x11,
  0x12,
  0x13,
  0x14,
  0x15,
  0x16,
  0x17,
  0x18,
  // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
  0x19,
  0x1A,
  0x1B,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
  0xFF,
  // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF
  // 'x', 'y', 'z', '{', '|', '}', '~', 'DEL'
];

List<int> base32decode(String input) {
  int index = 0, lookup, offset = 0, digit;
  Uint8List bytes = Uint8List(input.length * 5 ~/ 8);

  for (int i = 0; i < input.length; i++) {
    lookup = input.codeUnitAt(i) - 48;
    if (lookup < 0 || lookup >= _base32Lookup.length) continue;

    digit = _base32Lookup[lookup];
    if (digit == 0xFF) continue;

    if (index <= 3) {
      index = (index + 5) % 8;
      if (index == 0) {
        bytes[offset] |= digit;
        offset++;
        if (offset >= bytes.length) break;
      } else {
        bytes[offset] |= digit << (8 - index);
      }
    } else {
      index = (index + 5) % 8;
      bytes[offset] |= (digit >> index);
      offset++;

      if (offset >= bytes.length) break;

      bytes[offset] |= digit << (8 - index);
    }
  }
  return bytes;
}

# Globally Unique ID Generator

> This project is a dart implementation of the Go Lang library found here: [https://github.com/rs/xid](https://github.com/rs/xid)

__ReadMe is from that project (with some modifications for dart).__

Package xid is a globally unique id generator library, ready to be used safely directly in your server code.

Xid is using Mongo Object ID algorithm to generate globally unique ids with a different serialization (base64) to make it shorter when transported as a string:
https://docs.mongodb.org/manual/reference/object-id/

- 4-byte value representing the seconds since the Unix epoch,
- 3-byte machine identifier,
- 2-byte process id, and
- 3-byte counter, starting with a random value.

The binary representation of the id is compatible with Mongo 12 bytes Object IDs.
The string representation is using base32 hex (w/o padding) for better space efficiency
when stored in that form (20 bytes). The hex variant of base32 is used to retain the
sortable property of the id.

Xid doesn't use base64 because case sensitivity and the 2 non alphanum chars may be an
issue when transported as a string between various systems. Base36 wasn't retained either
because 1/ it's not standard 2/ the resulting size is not predictable (not bit aligned)
and 3/ it would not remain sortable. To validate a base32 `xid`, expect a 20 chars long,
all lowercase sequence of `a` to `v` letters and `0` to `9` numbers (`[0-9a-v]{20}`).

UUIDs are 16 bytes (128 bits) and 36 chars as string representation. Twitter Snowflake
ids are 8 bytes (64 bits) but require machine/data-center configuration and/or central
generator servers. xid stands in between with 12 bytes (96 bits) and a more compact
URL-safe string representation (20 chars). No configuration or central generator server
is required so it can be used directly in server's code.

| Name        | Binary Size | String Size    | Features
|-------------|-------------|----------------|----------------
| [UUID]      | 16 bytes    | 36 chars       | configuration free, not sortable
| [shortuuid] | 16 bytes    | 22 chars       | configuration free, not sortable
| [Snowflake] | 8 bytes     | up to 20 chars | needs machin/DC configuration, needs central server, sortable
| [MongoID]   | 12 bytes    | 24 chars       | configuration free, sortable
| xid         | 12 bytes    | 20 chars       | configuration free, sortable

[UUID]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[shortuuid]: https://github.com/stochastic-technologies/shortuuid
[Snowflake]: https://blog.twitter.com/2010/announcing-snowflake
[MongoID]: https://docs.mongodb.org/manual/reference/object-id/

Features:

- Size: 12 bytes (96 bits), smaller than UUID, larger than snowflake
- Base32 hex encoded by default (20 chars when transported as printable string, still sortable)
- Non configured, you don't need set a unique machine and/or data center id
- K-ordered
- Embedded time with 1 second precision
- Unicity guaranteed for 16,777,216 (24 bits) unique ids per second and per host/process

References:

- http://www.slideshare.net/davegardnerisme/unique-id-generation-in-distributed-systems
- https://en.wikipedia.org/wiki/Universally_unique_identifier
- https://blog.twitter.com/2010/announcing-snowflake

## Usage

```dart
import 'package:xid/xid.dart';

void main() {
  var xid = Xid();
  print('generated id: $xid');

}

// generated id: 9m4e2mr0ui3e8a215n4g
```

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/graham/python_xid/master/LICENSE).

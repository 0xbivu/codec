# codec

Small bash script for encoding/decoding stuff without opening CyberChef.
Needs bash 4.4+ and GNU coreutils 8.31+ (`basenc`).

```
codec [-d] <format>[,format...] [text]
```

Formats: `b64` `b64url` `b32` `b58` `hex` `bin` `dec` `oct` `url` `html` `rot13`

```sh
$ codec b64 hello
aGVsbG8=
$ echo aGVsbG8 | codec -d b64          # missing padding is fine
hello
$ codec url 'a b&c'
a%20b%26c
$ codec -d hex 68:65 0x6c '\x6c' 6f   # separators/prefixes don't matter
hello
$ codec dec hi
104 105
$ codec -d html '&lt;&#x41;&#66;&gt;'
<AB>
```

Chain formats with commas, applied left to right:

```sh
$ codec hex,b64 hi
Njg2OQ==
$ codec -d b64,hex Njg2OQ==
hi
```

Reads stdin when no text is given, so it pipes: `codec b64 < file > out`.
Decoding rejects garbage (bad padding, `%GG`, NUL bytes, ...) with a nonzero exit.

b58 is pure bash bignum math, so keep it to keys/addresses, not files.

Install: `ln -s "$PWD/codec" ~/.local/bin/codec`

Tests: `./test.sh`

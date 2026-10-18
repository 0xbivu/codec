# codec

Small bash script for encoding/decoding stuff without opening CyberChef.

## Install

```sh
git clone https://github.com/0xbivu/codec.git
cd codec
./test.sh                                   # optional, should print all ok
mkdir -p ~/.local/bin
ln -s "$PWD/codec" ~/.local/bin/codec
```

Then `codec -h` from anywhere. If you get `command not found`, `~/.local/bin`
isn't on your PATH yet:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # or ~/.zshrc
```

Prefer a system-wide install? `sudo cp codec /usr/local/bin/`

Since it's a symlink, `git pull` in the repo updates it. To remove it:
`rm ~/.local/bin/codec`.

## Usage

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

---

Built with help from Claude.

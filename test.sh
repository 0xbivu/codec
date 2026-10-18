#!/usr/bin/env bash
# round-trip every format, plus a few known values
set -o pipefail
cd "$(dirname "$0")"
fail=0

# t <cmd> <want> <name> -- fails on wrong output or nonzero exit
t() {
	local got
	got=$(eval "$1") || { echo "FAIL $3: exit $?"; fail=1; return; }
	[[ $got == "$2" ]] && echo "ok   $3" || { echo "FAIL $3: got '$got' want '$2'"; fail=1; }
}

hexof() { od -An -tx1 | tr -d ' \n'; }

s='hello world/?&= é \n%41 <a href="x">'
for f in b64 b64url b32 b58 hex bin dec oct url html rot13; do
	t "./codec $f '$s' | ./codec -d $f" "$s" "$f roundtrip"
	# raw bytes incl. NUL and trailing newlines; text-only formats skip the NUL
	raw='\0a\0b\n\n'
	[[ $f == html || $f == rot13 ]] && raw='a\nb\n\n'
	t "printf '$raw' | ./codec $f | ./codec -d $f | hexof" "$(printf "$raw" | hexof)" "$f bytes"
done

t "./codec b64 hi" "aGk=" "b64"
t "./codec -d b64 aGk" "hi" "b64 no padding"
t "./codec b58 'hello world'" "StV1DL6CwTryKyV" "b58"
t "printf '\0\0a' | ./codec b58" "112g" "b58 leading zeros"
t "./codec -d hex '0x68 0x69'" "hi" "hex 0x prefix"
t "./codec -d hex 'de:ad' | hexof" "dead" "hex colons"
t "./codec -d hex '\x68\x69'" "hi" "hex \\x"
t "./codec bin A" "01000001" "bin"
t "./codec dec hi" "104 105" "dec"
t "./codec -d dec 104,105" "hi" "dec commas"
t "./codec oct hi" "150 151" "oct"
t "./codec url 'a b&c'" "a%20b%26c" "url"
t "./codec -d url 'a+b%26c'" "a b&c" "url plus"
t "./codec html '<a>&'" "&lt;a&gt;&amp;" "html"
t "./codec -d html '&#x41;&#66;&amp;&lt;'" "AB&<" "html numeric"
t "./codec rot13 hi | hexof" "7576" "rot13 no extra newline"
t "./codec hex,b64 hi" "Njg2OQ==" "chain"
t "./codec -d b64,hex Njg2OQ==" "hi" "chain decode"
t "./codec -h | head -1" "usage: codec [-d] <format>[,format...] [text]" "help"

# these must fail
t "! ./codec -d url %GG 2>/dev/null" "" "url rejects bad escape"
t "! printf 'aG\0k=' | ./codec -d b64 2>/dev/null" "" "rejects NUL"
t "! ./codec -d dec 256 2>/dev/null" "" "dec rejects >255"
t "! ./codec -d b58 0OIl 2>/dev/null" "" "b58 rejects bad char"
t "! ./codec nope x 2>/dev/null" "" "unknown format"
t "! ./codec -d html '&#xD800;' 2>/dev/null" "" "html rejects surrogate"
t "! ./codec -d html 'a&#0;b' 2>/dev/null" "" "html rejects &#0;"
t "LC_ALL=C ./codec -d html '&#233;'" "é" "html in C locale"
t "! (cd /proc && ~/development/codec/codec -d dec '[1]' 2>/dev/null)" "" "dec no glob"
exit $fail

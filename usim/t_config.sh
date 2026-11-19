#!/bin/sh
#
# t_config.sh --- check that usim can print its running configuration
#
# -p is how a usim.ini is generated in the first place, so the checks
# below run usim in an empty directory: no usim.ini, no disk pack, and
# no ../sys, which is the state someone starting out is in.
#
# Run it from the tree it belongs to, with usim already built.

here=$(dirname "$0")
USIM=$(cd "$here" && pwd)/usim

if [ ! -x "$USIM" ]; then
	echo "t_config.sh: $USIM is not built"
	exit 1
fi

passed=0
failed=0

ck()
{
	if [ "$2" = "$3" ]; then
		passed=$((passed + 1))
	else
		echo "FAIL - $1: expected [$3] got [$2]"
		failed=$((failed + 1))
	fi
}

D=$(mktemp -d) || exit 1
cd "$D" || exit 1

# an empty directory: the defaults name disk.img and ../sys/ubin, and
# neither is here
out=$("$USIM" -p 2>stderr.txt)
ck "-p exits 0 with no usim.ini" "$?" "0"
ck "-p writes nothing to stderr" "$(wc -c <stderr.txt)" "0"
ck "-p prints the usim section" "$(echo "$out" | grep -c '^\[usim\]$')" "1"
ck "-p prints the disk section" "$(echo "$out" | grep -c '^\[disk\]$')" "1"
ck "-p normalises the default disk" "$(echo "$out" | grep -c '^disk0 = T-300,disk.img$')" "1"
ck "-p prints no banner" "$(echo "$out" | grep -c 'CADR emulator')" "0"

# - is stdout spelled out, and has to agree with the bare form
out2=$("$USIM" -p - 2>/dev/null)
ck "-p - exits 0" "$?" "0"
ck "-p - agrees with -p" "$(test "$out" = "$out2" && echo yes)" "yes"

# and a filename writes the same thing to that file
"$USIM" -p usim.ini >/dev/null 2>&1
ck "-p FILE exits 0" "$?" "0"
ck "-p FILE writes the same" "$(test "$(cat usim.ini)" = "$out" && echo yes)" "yes"

# what -p generates has to be something usim accepts, and dumping it
# again has to give the same thing back
out3=$("$USIM" -c usim.ini -p 2>/dev/null)
ck "generated usim.ini loads" "$?" "0"
ck "generated usim.ini round trips" "$(test "$out3" = "$out" && echo yes)" "yes"

# a diskN line that is present but empty leaves the unit without a
# type, which used to crash the dump
printf '[disk]\ndisk0 = \n' >empty.ini
"$USIM" -c empty.ini -p >/dev/null 2>&1
ck "an empty diskN does not crash" "$?" "0"

# sys_directory lives in ucfg, not in the global of the same name
printf '[usim]\nsys_directory = /tmp/sys\n' >sys.ini
ck "sys_directory is dumped" "$("$USIM" -c sys.ini -p 2>/dev/null | grep -c '^sys_directory = /tmp/sys$')" "1"

# without -p a missing disk pack is still fatal
"$USIM" -H >/dev/null 2>&1
ck "a normal run still fails" "$?" "1"

cd / || exit 1
rm -rf "$D"

echo "t_config.sh: $passed passed, $failed failed"
[ "$failed" -eq 0 ]

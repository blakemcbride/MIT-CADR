#!/bin/sh
#
# t_mcr.sh --- check diskmaker's restore-mcr and dump-mcr
#
# An MCR file stores a 32 bit word with its two 16 bit halves swapped
# with respect to the order a disk pack uses, so a microload cannot be
# copied into a partition the way a band can.  The conversion is its
# own inverse, so restoring a microload and dumping it back has to give
# the same file.
#
# The first part builds its own microload and its own small pack, so it
# runs anywhere.  The checks that need a real microcode file, a band or
# a bootable pack skip themselves when those are not in the tree; set
# USIM_TEST_BAND to name a band file if it is somewhere else.

here=$(cd "$(dirname "$0")" && pwd)
DISKMAKER=$here/diskmaker
READMCR=$here/readmcr
USIM=$here/usim
UCADR=$here/../sys/ubin/ucadr.mcr

if [ ! -x "$DISKMAKER" ]; then
	echo "t_mcr.sh: $DISKMAKER is not built"
	exit 1
fi

passed=0
failed=0
skipped=0

ck()
{
	if [ "$2" = "$3" ]; then
		passed=$((passed + 1))
	else
		echo "FAIL - $1: expected [$3] got [$2]"
		failed=$((failed + 1))
	fi
}

skip()
{
	echo "skip - $1"
	skipped=$((skipped + 1))
}

# one 32 bit word of a microload, in the order an MCR file uses
w()
{
	lo=$(printf '%03o' $(($1 & 255)))
	hi=$(printf '%03o' $((($1 >> 8) & 255)))
	printf "\\000\\000\\$lo\\$hi"
}

D=$(mktemp -d) || exit 1
cd "$D" || exit 1

# a pack big enough to hold a microload and nothing more.  diskmaker
# does not care about drive types, only usim does, so the geometry here
# is whatever keeps the checks quick
cat >small.template <<TEMPLATE
cylinders	20
heads		2
blockspertrack	17
drive		Test
pack		test
comment		test
mcr MCR1
lod LOD1
partitions:
MCR1	-	0224
LOD1	-	-
TEMPLATE

"$DISKMAKER" create-disk-pack small.img small.template >/dev/null 2>&1
ck "pack created" "$(wc -c <small.img)" "696320"

# a microload of four sections.  The main memory section is the awkward
# one: the two words after its code are a block count and a block
# offset, not the start and size the others use, so this microload is
# three blocks long while its section stream is only 88 bytes
{
	w 1; w 0; w 2;   w 0; w 0; w 0; w 0	# I memory, 2 microinstructions
	w 2; w 0; w 3;   w 0; w 0; w 0		# D memory, 3 words
	w 3; w 2; w 1;   w 0			# main memory, 2 blocks at block 1
	w 4; w 0; w 2;   w 0; w 0		# A memory, 2 words, ends the load
} >tiny.mcr
dd if=/dev/zero bs=1 count=2984 >>tiny.mcr 2>/dev/null
ck "microload built" "$(wc -c <tiny.mcr)" "3072"

out=$("$DISKMAKER" restore-mcr tiny.mcr small.img MCR1 2>&1)
ck "restore-mcr exits 0" "$?" "0"
ck "restore-mcr counts the blocks" "$(echo "$out" | grep -c '3072 bytes (3 blocks)')" "1"
ck "restore-mcr labels the partition" "$("$DISKMAKER" show-disk-pack small.img | grep -c "^MCR1:.*'tiny.mcr'")" "1"

# the pack holds native order words now, so the section code reads as 1
ck "the first word is 1" "$(dd if=small.img bs=1024 skip=17 count=1 2>/dev/null | od -A n -t u4 -N 4 | tr -d ' ')" "1"

"$DISKMAKER" dump-mcr small.img MCR1 tiny.out >/dev/null 2>&1
ck "dump-mcr exits 0" "$?" "0"
cmp -s tiny.out tiny.mcr
ck "dump-mcr round trips" "$?" "0"

# a microload is validated on the way in, so none of these may be written.
# An empty partition reads as section code 0, which is what a pack whose
# MCR partition was never filled looks like
dd if=/dev/zero of=zeros.bin bs=1024 count=4 >/dev/null 2>&1
"$DISKMAKER" restore-mcr zeros.bin small.img MCR1 >/dev/null 2>&1
ck "an empty file is rejected" "$?" "1"

{ w 99; w 0; w 0; } >junk.bin
dd if=/dev/zero bs=1 count=1012 >>junk.bin 2>/dev/null
"$DISKMAKER" restore-mcr junk.bin small.img MCR1 >/dev/null 2>&1
ck "an unknown section code is rejected" "$?" "1"

dd if=/dev/zero of=big.bin bs=1024 count=200 >/dev/null 2>&1
"$DISKMAKER" restore-mcr big.bin small.img MCR1 >/dev/null 2>&1
ck "an oversized file is rejected" "$?" "1"

printf '123' >odd.bin
"$DISKMAKER" restore-mcr odd.bin small.img MCR1 >/dev/null 2>&1
ck "a partial word is rejected" "$?" "1"

"$DISKMAKER" restore-mcr tiny.mcr small.img ZZZZ >/dev/null 2>&1
ck "an unknown partition is rejected" "$?" "1"

# the same round trip on the real thing, if it is in the tree
if [ -f "$UCADR" ]; then
	"$DISKMAKER" restore-mcr "$UCADR" small.img MCR1 >/dev/null 2>&1
	ck "ucadr.mcr restores" "$?" "0"
	"$DISKMAKER" dump-mcr small.img MCR1 ucadr.out >/dev/null 2>&1
	cmp -s ucadr.out "$UCADR"
	ck "ucadr.mcr round trips" "$?" "0"

	if [ -x "$READMCR" ]; then
		ck "readmcr reads what came back" \
			"$(test "$("$READMCR" ucadr.out)" = "$("$READMCR" "$UCADR")" && echo yes)" "yes"
	else
		skip "readmcr is not built"
	fi
else
	skip "no microcode at $UCADR"
fi

# and a pack built from nothing has to boot, which needs a band
band=$USIM_TEST_BAND
if [ -z "$band" ]; then
	band=$(ls "$here"/LOD* 2>/dev/null | head -1)
fi

if [ -f "$UCADR" ] && [ -x "$USIM" ] && [ -n "$band" ] && [ -f "$band" ] &&
	command -v timeout >/dev/null 2>&1; then
	"$DISKMAKER" create-disk-pack boot.img "$here/diskmaker.t300.template" >/dev/null 2>&1
	"$DISKMAKER" restore-mcr "$UCADR" boot.img MCR1 >/dev/null 2>&1
	"$DISKMAKER" restore-band "$band" boot.img LOD1 >/dev/null 2>&1

	cat >boot.ini <<INI
[usim]
headless = true
[ucode]
prommcr_filename = $here/../sys/ubin/promh.mcr
promsym_filename = $here/../sys/ubin/promh.sym
mcrsym_filename = $here/../sys/ubin/ucadr.sym
[chaos]
hosts = $here/hosts.text
[disk]
disk0 = T-300,$D/boot.img
INI
	timeout 60 "$USIM" -c boot.ini >boot.log 2>&1
	ck "the machine boots" "$(grep -c 'CADR booting' boot.log)" "1"
	ck "it gets out of the PROM" "$(grep -c 'in the PROM' boot.log)" "0"
else
	skip "no band, no microcode or no timeout, cannot check a boot"
fi

cd / || exit 1
rm -rf "$D"

echo "t_mcr.sh: $passed passed, $failed failed, $skipped skipped"
[ "$failed" -eq 0 ]

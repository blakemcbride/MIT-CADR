# Top-level Makefile for the MIT CADR Lisp Machine (LM-3, System 303)
#
#   make            build the simulator and tools, unpack the disk image
#   make run        build if needed, then start the Lisp Machine
#   make BACKEND=x11   use the X11 backend instead of SDL3 (also: sdl2)
#   make check      run the simulator's test suite
#   make reset-disk    discard the working disk image, restore the pristine one
#   make clean      remove build products (keeps the working disk image)
#   make distclean  clean + remove the working disk image and saved state

BACKEND ?= sdl3

DISK     = disks/disk-sys-303-0.img
DISK_GZ  = $(DISK).gz

.PHONY: all usim tools run check reset-disk clean distclean help

all: usim tools $(DISK)

usim:
	$(MAKE) -C usim $(BACKEND)

tools:
	$(MAKE) -C usim tools

# The pristine image is kept compressed in git; the simulator writes to
# the unpacked working copy, which is not tracked.
$(DISK): $(DISK_GZ)
	gzip -dc $(DISK_GZ) > $(DISK).tmp
	mv $(DISK).tmp $(DISK)

run: all
	./run

check: usim tools
	$(MAKE) -C usim check

reset-disk:
	rm -f $(DISK)
	$(MAKE) $(DISK)

clean:
	$(MAKE) -C usim clean
	$(MAKE) -C chaos/libhosts clean

distclean: clean
	rm -f $(DISK) $(DISK).tmp usim.state usim-*.state usim-*.pbm

help:
	@sed -n '3,9p' Makefile

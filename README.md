# MIT CADR Lisp Machine

A complete, self-contained, runnable MIT CADR Lisp Machine: the `usim`
CADR simulator, the Lisp Machine **System 303.0** software (sources,
microcode and a bootable disk image), a stand-alone site configuration,
and the manuals.

Everything here comes from the [LM-3 project](https://tumbleweed.nu/lm-3)
("resurrecting the MIT CADR"), gathered into one tree so that a single
`make` produces a working machine with no further downloads.

## Quick start

```sh
make        # build the simulator and tools, unpack the disk image
./run       # boot the Lisp Machine
```

A window opens and the machine cold-boots into a Lisp Listener in under
a minute. If it asks `Please type the date and time:`, answer in a form
such as `11/19/26 14:30`.

Then try:

```lisp
(+ 1 2)
(login 'lispm)          ; log in; gives access to the host file system
(ed)                    ; Zmacs, the editor  (or press System E)
(print-disk-label)      ; show the bands on the disk
```

Leave by closing the window. To shut the machine down cleanly first,
evaluate `(si:%halt)`.

## Requirements

A C compiler, GNU make, gzip and one display library:

| Backend | `make` invocation       | Fedora                    | Debian / Ubuntu          |
| ------- | ----------------------- | ------------------------- | ------------------------ |
| SDL3    | `make` (default)        | `SDL3-devel`              | `libsdl3-dev`            |
| SDL2    | `make BACKEND=sdl2`     | `SDL2-devel libX11-devel` | `libsdl2-dev libx11-dev` |
| X11     | `make BACKEND=x11`      | `libX11-devel`            | `libx11-dev`             |

Tested on Linux x86-64 (Fedora 44, GCC, SDL 3.4). Upstream also supports
macOS and the BSDs.

## Make targets

| Target            | What it does                                                   |
| ----------------- | -------------------------------------------------------------- |
| `make`            | Build `usim`, the tools, and unpack the disk image             |
| `make run`        | Build if necessary, then boot                                  |
| `make check`      | Run the simulator's test suite                                 |
| `make reset-disk` | Throw away the working disk image and restore the pristine one |
| `make clean`      | Remove build products (the working disk image is kept)         |
| `make distclean`  | `clean`, plus remove the working disk image and saved state    |

## Layout

| Path         | Contents                                                                           |
| ------------ | ---------------------------------------------------------------------------------- |
| `usim/`      | The CADR simulator and tools (`diskmaker`, `lod`, `readmcr`, `showmcr`, `di`)       |
| `chaos/`     | Chaosnet for Unix; `usim` compiles its FILE server and host-table code from here   |
| `sys/`       | Lisp Machine System 303 sources, compiled files (QFASL), microcode and boot PROM   |
| `usite/`     | Site configuration for a stand-alone machine (`LOCAL-CADR` / `LOCAL-BRIDGE`)       |
| `disks/`     | `disk-sys-303-0.img.gz`, the pristine System 303.0 disk image                      |
| `doc/`       | Manuals (HTML)                                                                     |
| `usim.ini`   | Simulator configuration used by `./run`                                            |
| `run`        | Starts the simulator from the top of the tree                                      |

`sys/` keeps the Lisp Machine convention of numbered file versions
(`foo.lisp.42`) next to the newest version (`foo.lisp`). Do not rename or
prune them; the machine reads them by those names.

## The disk image

The pristine image is stored compressed (79 MB) in `disks/`. `make`
unpacks it to `disks/disk-sys-303-0.img` (257 MB), which is the copy the
machine reads and **writes** — paging, `disk-save` and the local file
system all go there. That working copy is not tracked by git; `make
reset-disk` restores it to the original.

## Host file access

The simulator contains its own Chaosnet and FILE server (no daemon and
no network access are needed). The top of this repository is served to
the Lisp Machine as the root of host `LOCAL-BRIDGE`, so after
`(login 'lispm)` the system sources are reachable as `SYS: ...` and any
file in the tree as, for example, `local-bridge://usite//site.lisp`.
The mapping is `fs_root_directory` in `usim.ini`.

## Keyboard (SDL3 backend)

The host keyboard is presented as a Space-Cadet keyboard.

| Host key        | Lisp Machine key | Host key      | Lisp Machine key |
| --------------- | ---------------- | ------------- | ---------------- |
| F1              | System           | Escape        | Altmode          |
| F2              | Network          | Home          | Break            |
| F3              | Status           | End           | End              |
| F4              | Terminal         | Page Up       | Abort            |
| F5              | Help             | Page Down     | Resume           |
| F6              | Clear-Input      | Alt           | Meta             |
| F7              | Clear-Screen     | Win / Super   | Super            |
| Backspace       | Rubout           | Arrow keys    | Hand keys        |

Keys can be remapped in a `[kbd]` section of `usim.ini`; see
`usim/README.md`, which documents every configuration option, the other
backends, headless operation (`./run -H`) and saved machine state.

## Documentation

In `doc/`:

- `operat.html` — *Operating the Lisp Machine*: start here
- `chinual.html` — the *Lisp Machine Manual*
- `wind.html` — *Introduction to Using the Window System*
- `cadr.html` — *The CADR Microprocessor* (AI Memo 528), the hardware

Component documentation: `usim/README.md`, `usim/DEVELOPMENT.md`,
`chaos/README.md`, and `usite/-read-.-this-` (making your own site,
setting up the local file system, saving a customised band).

## Origin and changes

| Component        | Upstream (Fossil)                                      | Version taken              |
| ---------------- | ------------------------------------------------------ | -------------------------- |
| `usim/`          | <https://tumbleweed.nu/r/usim>                         | trunk, 2026-09-04          |
| `chaos/`         | <https://tumbleweed.nu/r/chaos>                        | trunk, 2025-09-01          |
| `sys/`           | <https://tumbleweed.nu/r/sys>                          | branch `system-303`        |
| `usite/`         | <https://tumbleweed.nu/r/usite>                        | trunk, 2025-05-08          |
| `disks/`         | <https://tumbleweed.nu/system-303-0-release/>          | `disk-sys-303-0.img.gz`    |
| `doc/`           | <https://tumbleweed.nu/lm-3>                           | fetched 2026-11-19         |

Changes made here, relative to upstream:

- Added the top-level `Makefile`, `run`, `usim.ini` and this README.
  `usim.ini` replaces upstream's `usim-303-0.ini`, which uses a
  `disk0_filename` key the current simulator no longer accepts, and
  uses paths relative to the top of this tree.
- `usim/Makefile.usim` and `usim/Makefile.talu`: `$(PWD)` changed to
  `$(CURDIR)` so the build works when invoked as `make -C usim`.
- `doc/*.html`: the stylesheet link points at the local `texinfo.css`.
- Fossil metadata directories (`.fossil-settings`) were dropped.

## Credits and licences

- **usim** and **Chaosnet for Unix** were written by Brad Parker and
  are maintained by the LM-3 project (Alfred M. Szmidt and
  contributors). `usim` is under a two-clause BSD licence; see
  `usim/COPYING.md`.
- The **Lisp Machine system software** in `sys/` was written at the MIT
  Artificial Intelligence Laboratory and has been maintained since by
  the LM-3 project. The tree carries no licence file of its own; see
  the upstream project for its terms before redistributing.
- The manuals are the work of their original MIT authors, converted to
  Texinfo/HTML by the LM-3 project.

Bugs in the simulator or system software are best reported upstream:
<https://tumbleweed.nu/r/bug-lispm>.

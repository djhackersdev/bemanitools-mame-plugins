# Bemanitools MAME plugins

Version: `0.04`

MAME Lua plugins to hook up implementations of supported [Bemanitools](https://github.com/djhackersdev/bemanitools)
APIs, e.g. IO hardware in actual arcade cabinets or custom IO hardware.

Currently supported:

* Beatmania IIDX,
  [twinkle system](https://github.com/mamedev/mame/blob/master/src/mame/konami/twinkle.cpp) to
  [iidxio API](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md)
* Dance Dance Revolution,
  [system 573 digital system](https://github.com/mamedev/mame/blob/master/src/mame/konami/ksys573.cpp)
  to [ddrio API](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md)

## Remarks and (current) limitations

* When setting up MAME for any of the Bemani games, do read and follow
  [987123879113's wiki](https://github.com/987123879113/mame/wiki). It contains very relevant and
  important information and setup instructions to setup the games properly and get optimal
  performance regarding smooth framerate and accurate game play timing.
* Tested and verified working with
  * Official [MAME 0.259](https://github.com/mamedev/mame/releases/tag/mame0259)
  * 987123879113's 
    [Bemani branch](https://github.com/987123879113/mame/commit/200dc5396e06e74536546cad5ebdddbb9c41a0f4) of his MAME
    fork
* The lua bind libraries, i.e. `ddrio_lua_bind.dll` and `iidxio_lua_bind.dll`, use
  [Lua 5.4.0](https://sourceforge.net/projects/luabinaries/files/5.4.0/Windows%20Libraries/Dynamic/lua-5.4.0_Win64_dllw6_lib.zip/download) (included in this repository and the binary distribution zip) which must match the same
  major + minor Lua version your target MAME version is using. This is not an issue with the
  versions mentioned above.
  * Using a different MAME version, you can check the Lua version used by MAME by running the Lua
    REPL of MAME, i.e. `mame.exe -console`.
  * The lua version must match exactly to ensure ABI compatibility. Otherwise, stuff will crash in
    very odd ways and likely without proper error/debug output
* The `iidxio` Lua plugin does not merge analog inputs. Any configured analog inputs, e.g.
  turntables, from MAME's input manager will not work. Digital inputs, e.g. 14 key buttons, however
  are merged and should work.
* Built-in "game exit button combination": When enabled (not enabled by default), use 
  *Start P1* + *Start P2* + *VEFX* + *Effect* to exit the game.

## Building

### Local

Tested and working on Linux and MacOSX. Install the following tools with your favorite package
manager or `brew` on MacOSX:

* (gnu)make
* `x86_64-w64-mingw32-*` tools
* zip

To build the project:

```sh
make
```

The distribution zip-files `iidxio-mame-plugin.zip` and `ddrio-mame-plugin.zip` are located in
the `build` sub-directory.

### Docker

Naturally, docker required. Any dependencies installed in container. To run the build container:

```sh
make build-docker
```

The distribution zip-files `iidxio-mame-plugin.zip` and `ddrio-mame-plugin.zip` are located in the
`build/docker` sub-directory.

## Deployment to MAME

The following explains how to deploy the iidxio distribution package to MAME. To deploy the ddrio
plugin, follow the same steps just with the other distribution package.

### Deployment process with iidxio

Unpack the contents of `iidxio-mame-plugin.zip` to your `mame` installation folder. This merges
the `plugin` folder and `iidxio_lua_bind.dll` should be co-located next to `mame.exe`.

Pick a
[iidxio API implementation](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md#implementations) of your choice and put the files into the root folder of MAME, so the files
are co-located next to `iidxio_lua_bind.dll`. Ensure your iidxio implementation is named **exactly**
`iidxio.dll`. `iidxio_lua_bind.dll` is linked to `iidxio.dll` and is looking for this file.

IMPORTANT: With MAME supporting 64-bit only today, `iidxio_lua_bind.dll` is compiled as a 64-bit
binary, only. Therefore, ensure any implementations of `iidxio.dll` are compiled as 64-bit binaries.

Any dependencies to your `iidxio.dll` must also be located next to it accordingly to avoid "module
not found" errors.

The plugin `plugins/iidxio` is activated by default and runs automatically when running MAME.

Depending on iidxio implementation used, e.g. [BIO2](#example-iidxio-bio2) or
[iidxio geninput](#example-iidxio-default-implementation), you should see some output on the
command line by those libraries if they got picked up correctly and the plugin works.

### Example: iidxio-bio2

The
[BIO2 implementation of iidxio](https://github.com/djhackersdev/bemanitools/blob/master/doc/iidxhook/iidxio-bio2.md)
requires the following files co-located in the same directory as `iidxio_lua_bind.dll`:

* `iidxio-bio2.dll`: Renamed to `iidxio.dll`
* `iidxio-bio2.conf`: Auto generated on first start if it doesn't exist
* `aciomgr.dll`

Source these files from your bemanitools binary distribution accordingly. Ensure to pick the 64-bit
versions.

### Example: ddrio-p3io

Use `ddrio-p3io.dll` in combination with `ddrio-async.dll` to improve performance as synchronous IO
calls of *ddrio-p3io* are highly IO bound, latency ~16 ms for one update cycle.

This introduces choppy framerate and bad input responsiveness to MAME.

The
[P3IO implementation of ddrio](https://github.com/djhackersdev/bemanitools/blob/master/doc/ddrhook/ddrio-p3io.md)
requires the following files co-located in the same directory as `ddrio_lua_bind.dll`:

* [`ddrio-async.dll`](https://github.com/djhackersdev/bemanitools/blob/master/doc/ddrhook/ddrio-async.md): Renamed to
  `ddrio.dll`
* `ddrio-p3io.dll`: Renamed to `ddrio-async-child.dll`
* `ddrio-p3io.conf`: Auto generated on first start if it doesn't exist

Source these files from your bemanitools binary distribution accordingly. Ensure to pick the 64-bit
versions.

#### Technical background

Combining *ddrio-async* with *ddrio-p3io*, the combined backend is able to drive inputs/outputs at a
rate of ~250hz = ~4 updates per frame. This results in an average input latency of ~4 ms which is as
good as it can get with the p3io hardware's performance limitations that I measured (see the 4 ms
for the IOCTL mentioned above).

This is more than good enough as as update frequency of the 573 hardware was slightly less than that
(I got told something ~180 hz?).

### Example: iidxio default implementation

The
[default iidxio implementation](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md#io-boards) uses `geninput.dll` as its backend to create a generic input system supporting
keyboard, joystick and mouse controls. While as a feature, this isn't something MAME cannot do
out-of-the-box, it can be very useful for testing and debugging purpose to use this iidxio implementation.

The following files co-located in the same directory as `iidxio_lua_bind.dll`:

* `config.exe`: Use this tool to configure your IO mappings
* `iidxio.dll`: The default/generic one, keep the name
* `geninput.dll`
* `vefxio.dll`

Source these files from your bemanitools binary distribution accordingly. Ensure to pick the 64-bit
versions.

## Debugging

* [MAME's command line documentation](https://docs.mamedev.org/commandline/commandline-all.html) as
  reference here

```bat
.\mame.exe -console -verbose -window -oslog -log -resolution 1024x768 ddr4mp
```

* Check if your mame setup boots to the game without the plugin activated/installed
* `-console` is a lua console/repl plugin included in MAME. Useful for poking around and getting
  more debug output about the lua environment
* `-verbose`: Enable verbose output, probably the most essential one
* Window + resolution option: To be able to see the command line output next to MAME running
* `-oslog` and `-log`: Enables error logging to the terminal
* Hotkeys F10/F11 to speed up emulation, e.g. faster installs and boot process for quicker test
  iterations

## Maintenance

### Managing and upgrading the lua version

The lua version used here needs to be compatible (read: identical) to whatever version your target
MAME version is using. Check the lua version on MAME by running MAME from the command line with the
argument `-console`. It starts the console plugin and prints the lua version somewhere at the top
of the output.

For upgrades/downgrades, grab the right version from
[here](https://sourceforge.net/projects/luabinaries/files/).

Replace the includes in `src/imports` as well as the `.dll`` file in `dist` accordingly.

You also need to re-generate the `.def` symbol file in `src/imports`. Run the following command
and replace parameters accordingly:

```shell
x86_64-w64-mingw32-dlltool -z out.def --export-all-symbols dist/lua54.dll
```

Cleanup the `out.def` file by removing all symbols except for the ones starting with `lua` and add
`LIBRARY lua54` at the top (replace the number according to the version of lua you use).

Update `Module.mk` if the version changed that it requires pointing to different files,
e.g. `lua54.dll`.

Update the lua binding libraries `ddrio-lua-bind.def` and `iidxio-lua-bind.def` to link to the
new/different lua version if required.

## High level technical information

The following items provide key high level technical information about the implementation.

[`iidxio-lua-bind`](src/main/iidxio-lua-bind/iidxio-lua-bind.c) is a C-library that expose [Bemanitools' iidx API](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md) to Lua.

The `iidxio` MAME Lua plugin uses
[MAME's Lua API](https://docs.mamedev.org/techspecs/luareference.html). It hooks callbacks into the
start and stop of the emulation's life cycle as well as at the end of each frame. Additional 
callbacks are set-up to "tap into memory" reads and writes on the twinkle system's memory map. These
memory taps dispatch based on the issued memory reads and writes commands as different IO
interactions plus a separate 14 key read/write data handler.

This setup is as close to the hardware as possible if it comes to emulation accuracy. When using any
of bemanitools' iidxio implementations backed by real hardware, e.g. ezusb, ezusb2 or BIO2, there
should not be concerns regarding negative performance or input latency. Naturally, that does not
account for running on weak hardware or when using bad/buggy/non-optimized iidxio implementations.

## Bonus: Memory/IO read/write call patterns

Useful for testing and debugging to understand how the Lua plugin is actually being driven by the
game itself. This can help debugging bugs or performance issues not just with the plugin but also
with any `iidxio` implementations used by the plugin.
*
To get the outputs below, simply add prints at the relevant positions in the
[`iidxio` Lua plugin](src/mame/plugins/iidxio/init.lua) and run the game. Here, the game used to
capture the output was `bmiidx8`.

Format:

* `twinkle_keys_read (0x1f240000 0xFFFF)`: `<function name in script> (<memory address>, <mask>)`
* `twinkle_io_read (0x1f220004 0xff 0x07)`: `<function name in script> (<memory address>, <mask>, <current io offset>)`

### Main menu

Scoped excerpt:

```text
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x1f): sliders 1 + 2 input
twinkle_io_write (0x1F220000 0xff 4f): 16seg single char output
twinkle_io_write (0x1F220000 0xff 57): 16seg single char output
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x27): sliders 3 + 4 input
twinkle_io_write (0x1F220000 0xff 5f): 16seg single char output
twinkle_io_write (0x1F220000 0xff 67): 16seg single char output
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x2f): sliders 5 input
twinkle_io_write (0x1F220000 0xff 6f): 16seg single char output
twinkle_io_write (0x1F220000 0xff 77): 16seg single char output
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x1f): sliders 1 + 2 input
twinkle_io_write (0x1F220000 0xff 7f): 16seg single char output
twinkle_io_write (0x1F220000 0xff 0x8f): neons output
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x27): sliders 3 + 4 input
frame_update
```

#### Observations

* 14key inputs polled twice per frame
* Button panel inputs and both turntables polled once per frame
* Slider groups are alternating every three frames
* 14key outputs written once per frame
* Outputs only written when actually changed

### Test menu

Different patterns depending on the sub-menu you are in. In I/O test menus,
the items to test on the sub-menu are naturally being queried per frame.

### Gameplay

Scoped excerpt:

```text
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x1f): sliders 1 + 2 input
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x27): sliders 3 + 4 input
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
frame_update
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_io_read (0x1f220004 0xff 0x07): button panel inputs
twinkle_io_read (0x1f220004 0xff 0x17): tt 2 input
twinkle_io_read (0x1f220004 0xff 0x0f): tt 1 input
twinkle_io_read (0x1f220004 0xff 0x2f): sliders 5 input
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
twinkle_keys_write (0x1f250000 0xFF): 14 key outputs
twinkle_keys_read (0x1f240000 0xFFFF): 14 key inputs
frame_update
```

#### Observations

* Very similar to main menu
* Two additional 14 key input polls per frame, total of 4 per frame
* One additional 14 key output write per frame, total of 2 per frame
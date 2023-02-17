# iidxio MAME plugin

A MAME Lua plugin to hook up all game IO by the
[twinkle system](https://github.com/mamedev/mame/blob/master/src/mame/konami/twinkle.cpp) to
[Bemanitools'](https://github.com/djhackersdev/bemanitools)
[iidxio API](https://github.com/djhackersdev/bemanitools/blob/master/doc/api.md).

This allows you to use any custom or real IO hardware implementing the iidxio API with any
Beatmania IIDX game supported by MAME. 

## Remarks

* Tested and verified working with
  * Official [MAME 0.251](https://github.com/mamedev/mame/releases/tag/mame0251)
  * 987123879113's 
    [Bemani branch](https://github.com/987123879113/mame/commit/9b651b0e5bd269ac5bcb4e63b73990b692aa6cdb) of his MAME fork
* `iidxio_lua_bind.dll` uses
  [Lua 5.3.6](https://sourceforge.net/projects/luabinaries/files/5.3.6/Windows%20Libraries/Dynamic/lua-5.3.6_Win64_dllw6_lib.zip/download) (included in this repository and the binary distribution
  zip) which must match the same major + minor Lua version your target MAME version is using. You
  can check the Lua version used by MAME by running the Lua REPL of MAME, i.e. `mame.exe -console`.
* The `iidxio` Lua plugin does not merge analog inputs. Any configured analog inputs, e.g.
  turntables, from MAME's input manager will not work. Digital inputs, e.g. 14 key buttons, however
  are merged and should work.

## Building

### Local

Tested and working on Linux and Mac. Install the following tools with your favorite package
manager or `brew` on Mac:

* (gnu)make
* `x86_64-w64-mingw32-*` tools
* zip

To build the project:

```sh
make
```

The distribution zip-file `iidxio-mame-plugin.zip` is located under the `build` sub-directory.

### Docker

Naturally, docker required. Any dependencies installed in container. To run the build container:

```sh
make build-docker
```

The distribution zip-file `iidxio-mame-plugin.zip` is located under the `build/docker`
sub-directory.

## Deployment and using with MAME

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
[BIO2 implementation of iidxio](https://github.com/djhackersdev/bemanitools/blob/master/doc/iidxhook/iidxio-bio2.md) requires the following files co-located in the same directory as
`iidxio_lua_bind.dll`:

* `iidxio-bio2.dll`: Renamed to `iidxio.dll`
* `iidxio-bio2.conf`
* `aciomgr.dll`

Source these files from your bemanitools binary distribution accordingly. Ensure to pick the 64-bit
versions.

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

## Bonus: iidx-exit-hook plugin

A small plugin to exit MAME using the pre-configured button combination, e.g. *Start P1* +
*Start P2* + *VEFX* + *Effect*. This can be useful for dedicated setups to allow game switching by
running a game selector/loader once the current game exits.

Just copy the entire plugin folder `iidx-exit-hook` to the `mame/plugins` folder of your local installation. This plugin does not have any Bemanitools dependencies and works without it or
the `iidxio` plugin.

The `iidx-exit-hook` plugin also works in combination with the `iidxio` plugin.

## Bonus: Memory/IO read/write call patterns

Useful for testing and debugging to understand how the Lua plugin is actually being driven by the
game itself. This can help debugging bugs or performance issues not just with the plugin but also
with any `iidxio` implementations used by the plugin.

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
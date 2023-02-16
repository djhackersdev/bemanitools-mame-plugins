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
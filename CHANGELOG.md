# Changelog

## 0.04

## 0.03

### Features

* Add plugin to support the ddrio Bemanitools API on System 573 digital games. No support for
  the analog games, yet
* Breaking change !!!: Updated to lua 5.4 to be compatible with MAME 0.259 and newer

### Fixes

* Enforce loading order by changing `iidx-exit-hook` plugin name to `iidxio-exit-hook`.
  When using `iidxio` and `iidxio-exit-hook` in combination, `iidxio` **must load before**
  `iidxio-exit-hook` for the latter to work.
* Merge `iidxio-exit-hook` functionality into `iidxio` plugin due to currently unresolved issues
  with multiple memory read/write hooks in lua plugin environment
* MAME (soft) machine reset re-triggering init function in Lua plugin scripts of `iidxio`
  and `iidxio-exit-hook`. Detect and block re-init

### Misc

## 0.02

* Improve (technical) documentation
* Add `iidx-exit-hook` plugin to exit the game using a pre-configured button combination. Useful
  for setups utilizing game selectors/loaders

## 0.01

* Initial release
# Changelog

## 0.05

### Features

### Fixes

### Misc

## 0.04

### Features

* Add plugin to support the ddrio Bemanitools API on System 573 digital games. No support for
  the analog games, yet
* Breaking change !!!: Updated to lua 5.4 to be compatible with MAME 0.259 and newer

### Fixes

N/A

### Misc

N/A

## 0.03

* Bugfix: Merge `iidxio-exit-hook` plugin with `iidxio` plugin because of plugin crashing after
  about 2-3 minutes running the game. Running two plugins writing/reading the same memory regions
  seems to be buggy for now.
* Bugfix: MAME (soft) machine reset re-triggering init function in Lua plugin scripts of `iidxio`
  and `iidxio-exit-hook`. Detect and block re-init

## 0.02

* Improve (technical) documentation
* Add `iidx-exit-hook` plugin to exit the game using a pre-configured button combination. Useful
  for setups utilizing game selectors/loaders

## 0.01

* Initial release
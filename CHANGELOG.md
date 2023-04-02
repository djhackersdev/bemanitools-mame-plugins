# Changelog

## 0.04

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
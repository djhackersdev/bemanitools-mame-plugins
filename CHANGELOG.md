# Changelog

## 0.03

* Bugfix: Enforce loading order by changing `iidx-exit-hook` plugin name to `iidxio-exit-hook`.
  When using `iidxio` and `iidxio-exit-hook` in combination, `iidxio` **must load before**
  `iidxio-exit-hook` for the latter to work.
* Bugfix: MAME (soft) machine reset re-triggering init function in Lua plugin scripts of `iidxio`
  and `iidxio-exit-hook`. Detect and block re-init

## 0.02

* Improve (technical) documentation
* Add `iidx-exit-hook` plugin to exit the game using a pre-configured button combination. Useful
  for setups utilizing game selectors/loaders

## 0.01

* Initial release
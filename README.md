# Alpine to AppImage

Converts Alpine Linux packages to AppImages using Docker, make, [witchery-compose](https://github.com/witchery-project/witchery/), and [go-appimage](https://github.com/probonopd/go-appimage).

## Pros

* Relatively straightforward
* The resulting AppImages should be able to run on glibc-based and on musl libc-based Linux distributions, even if they are _older_ than the distribution on which the binaries were compiled (Alpine edge)
* Since the ingredients come from Alpine and use musl libc, they do not rely on the target system's glibc version

## Cons

* AppImages created in this way may introduce _some_ overhead which could be optimized away by hand-crafting the AppImage instead of relying on [witchery-compose](https://github.com/witchery-project/witchery/) - however this could be mitigated by removing potentially unneeded files using additional `rm` commands

## Credits

* [__xordspar0__](https://github.com/xordspar0)
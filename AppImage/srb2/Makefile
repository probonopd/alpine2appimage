DOCKER=docker

.PHONY: appimage
appimage: witchery-compose appimagetool.AppImage
	rm -rf out
	mkdir out
	$(DOCKER) run \
		--volume "${PWD}:/src" \
		--volume "${PWD}/out:/out" \
		--env SRC_DIR=/src \
		--env OUT_DIR=/out \
		--rm \
		alpine:edge /src/build.sh

witchery-compose:
	wget https://raw.githubusercontent.com/witchery-project/witchery/refs/heads/master/witchery-compose
	chmod +x witchery-compose

appimagetool.AppImage:
	wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - \
		| grep "appimagetool-.*-$$(uname -m).AppImage" \
		| head -n 1 \
		| cut -d '"' -f 2 \
		| xargs -I url wget "https://github.com/url" -O appimagetool.AppImage
	chmod +x appimagetool.AppImage


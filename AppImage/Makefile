DOCKER=docker

.PHONY: appimage
appimage: witchery-compose appimagetool.AppImage
	@:$(if $(PACKAGE),,$(error PACKAGE is not set))
	sudo rm -rf "${PACKAGE}/out"
	mkdir -p "${PACKAGE}/out"
	$(DOCKER) run \
		--workdir /src \
		--volume "${PWD}/${PACKAGE}:/src" \
		--volume "${PWD}/${PACKAGE}/out:/out" \
		--volume "${PWD}/:/tools" \
		--env SRC_DIR=/src \
		--env OUT_DIR=/out \
		--env TOOLS_DIR=/tools \
		--env PACKAGE="${PACKAGE}" \
		--rm \
		alpine:edge sh -ex /src/build.sh

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


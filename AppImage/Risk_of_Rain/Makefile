RISK_OF_RAIN_ZIP = Risk_of_Rain_v1.3.0_DRM-Free_Linux_.zip

appimage:
	-rm -rf out
	mkdir out
	sudo docker run \
		--volume "${PWD}:/src" \
		--volume "${PWD}/out:/tmp/out" \
		--env RISK_OF_RAIN_ZIP="${RISK_OF_RAIN_ZIP}" \
		--workdir /src \
		ubuntu:14.04 ./build.sh

.PHONY: appimage

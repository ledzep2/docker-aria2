FROM lsiobase/alpine:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="blog.auska.win version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Auska"

ENV TZ=Asia/Shanghai ARIA2_VERSION=1.34.0 ARIANG_VERSION=1.1.0 SECRET=admin

RUN \
	echo "**** install packages ****" \
#	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk add --no-cache darkhttpd unzip \
	&& apk add --no-cache --virtual .build-deps build-base curl wget \
	&& apk add --no-cache ca-certificates zlib-dev openssl-dev expat-dev sqlite-dev c-ares-dev libssh2-dev \
	&& cd /tmp \
	&& curl -fSL https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip -o ariang.zip \
	&& mkdir -p /webui \
	&& unzip ariang.zip -d /webui \
	&& sed -i "s|'max-connection-per-server': {type: 'integer',defaultValue: '1',required: true,min: 1,max: 16}|'max-connection-per-server': {type: 'integer',defaul,required: true,min: 1}|g" /webui/js/aria-ng-*.min.js \
	&& curl -fSL https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.xz -o aria2.tar.xz \
	&& tar xJf aria2.tar.xz \
	&& cd aria2-${ARIA2_VERSION} \
	&& sed -i 's|"1", 1, 16,|"8", 1, -1,|g' src/OptionHandlerFactory.cc \
	&& ./configure --host=x86_64-alpine-linux-musl \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install-strip \
	&& apk del .build-deps \
	&& apk add libstdc++ \
	&& rm -rf /tmp

RUN apk add wget

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6800 80
VOLUME /mnt /config

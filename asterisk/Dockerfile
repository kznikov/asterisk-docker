FROM alpine:3.16

ENV ASTERISK_VERSION 18.11.2

# Add needed patches
ADD patches /tmp

# Install required dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
        bsd-compat-headers \
        make \
        dev86 \
        pkgconfig \
        subversion \
        jansson-dev \
        sqlite-dev \
        autoconf \
        automake \
        libtool \
        ncurses \
        libcap-dev \
        curl-dev \
        libedit-dev \
        libressl-dev \
        util-linux-dev \
        libxml2-dev \
        lua5.1-dev \
        mariadb-connector-c-dev \
        musl-dev \
        portaudio-dev \
        pjproject-dev \
        zlib-dev \
        patch \
        alsa-lib-dev \
        gsm-dev \
        speex-dev \
        speexdsp-dev \
        libsrtp-dev \
        curl \
        git \
        libsamplerate-dev \
# The ones we will not remove
    && apk add --no-cache openssl \
        c-client \
        jansson \
        ncurses-libs \
        libcap \
        libcurl \
        libedit \
        libressl \
        libuuid \
        libxml2 \
        lua5.1-libs \
        musl \
        portaudio \
        sqlite-libs \
        mariadb-connector-c \
        zlib \
        pjproject \
        ca-certificates \
        sngrep \
        gettext \
        vim \
        tzdata \

# Install beanstalkd dependencies
    && git clone https://github.com/deepfryed/beanstalk-client.git \
    && cd beanstalk-client && make install && cd .. \

# Build asterisk
    && curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar --strip-components 0 -xz || \
      curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz | tar --strip-components 0 -xz || \
      curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar --strip-components 0 -xz \

    && cd asterisk-* \

# Patch Asterisk
    && patch --ignore-whitespace -p1 </tmp/40-asterisk-cdefs.patch \
    && patch --ignore-whitespace -p1 </tmp/20-musl-astmm-fix.patch \
    && patch --ignore-whitespace -p1 </tmp/10-musl-mutex-init.patch \

    && ./configure --without-pjproject-bundled \
    && make menuselect.makeopts \
    && menuselect/menuselect \
# Required for asterisk to work ok in docker (check http://stackoverflow.com/a/19610145/920295)
    --disable BUILD_NATIVE \
# Addons
    --disable-category MENUSELECT_ADDONS \
    --enable res_config_mysql \
    --enable app_mysql \
# Apps
    --enable-category MENUSELECT_APPS \
# Bridges
    --enable-category MENUSELECT_BRIDGES \
# CDR
    --disable-category MENUSELECT_CDR \
    --enable cdr_beanstalkd \
    --enable cdr_manager \
# CELModel
    --disable-category MENUSELECT_CEL \
    --enable cel_beanstalkd \
# Channels
    --enable-category MENUSELECT_CHANNELS \
# Codecs
    --disable-category MENUSELECT_CODECS \
    --enable codec_alaw \
    --enable codec_ulaw \
# Formats
    --disable-category MENUSELECT_FORMATS \
    --enable format_pcm \
# Funcs
    --enable-category MENUSELECT_FUNCS \
# PBX
    --disable-category MENUSELECT_PBX \
    --enable pbx_config \
    --enable pbx_spool \
# RES
    --enable-category MENUSELECT_RES \
    --disable res_stir_shaken \
# Tests
    --disable-category MENUSELECT_TESTS \
# Cflags
    --disable-category MENUSELECT_CFLAGS \
# Utils
    --disable-category MENUSELECT_UTILS \
# AGIS
    --disable-category MENUSELECT_AGIS \
# Core sounds
    --disable-category MENUSELECT_CORE_SOUNDS \
# MOH
    --disable-category MENUSELECT_MOH \
# Extra Sounds
    --disable-category MENUSELECT_EXTRA_SOUNDS \
    menuselect.makeopts \

# Build
    && make && make install \

# Cleanup
    && cd .. && rm -rf asterisk-* \
    && rm -rf beanstalk-client \
    && rm -rf /tmp/*.patch \
    && sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk \
# Clean useless deps
    && apk del .build-deps && touch /firstrun

# Add modules configuration files
ADD conf/ /

# Configure the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD []

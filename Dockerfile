# Base
FROM lsiobase/alpine:3.8 as base

MAINTAINER "Simon Bergström <simon@menuan.se>"

ENV REFRESHED_AT=2018-09-06a \
  OTP_VER=21.0.6 \
  REBAR2_VER=2.6.4 \
  REBAR3_VER=3.6.1 \
  TERM=xterm \
  LANG=C.UTF-8 \
  MIX_HOME=/usr/local/lib/elixir/.mix

RUN set -xe \
  && apk --update --no-cache upgrade \
  && apk add --no-cache \
     bash \
     libressl \
     lksctp-tools \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

# deps
FROM base as deps

RUN set -xe \
  && apk add --no-cache --virtual .build-deps \
    autoconf \
    bash-dev \
    binutils-gold \
    curl curl-dev \
    dpkg dpkg-dev \
    g++ \
    gcc \
    libc-dev \
    libressl-dev \
    linux-headers \
    lksctp-tools-dev \
    make \
    musl musl-dev \
    ncurses ncurses-dev \
    rsync \
    tar \
    unixodbc unixodbc-dev \
  && update-ca-certificates --fresh

## erlang_build
FROM deps as erlang_build

RUN set -xe \
  && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VER}.tar.gz" \
  && OTP_DOWNLOAD_SHA256="a7da6ad97106b5ba087394658d41174ac1123d1f017bce02fbb9e43b49676f40" \
  && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
  && echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
  && export ERL_TOP="/usr/src/otp_src_${OTP_VER%%@*}" \
  && mkdir -vp $ERL_TOP \
  && tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
  && rm otp-src.tar.gz \
  && ( cd $ERL_TOP \
    && ./otp_build autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" \
      --without-javac \
      --without-wx \
      --without-debugger \
      --without-observer \
      --without-jinterface \
      --without-cosEvent\
      --without-cosEventDomain \
      --without-cosFileTransfer \
      --without-cosNotification \
      --without-cosProperty \
      --without-cosTime \
      --without-cosTransactions \
      --without-et \
      --without-gs \
      --without-ic \
      --without-megaco \
      --without-orber \
      --without-percept \
      --without-typer \
      --enable-threads \
      --enable-shared-zlib \
      --enable-ssl=dynamic-ssl-lib \
      --enable-kernel-poll \
      --enable-hipe \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install ) \
  && rm -rf $ERL_TOP

## erlang_minified
FROM erlang_build as erlang_minified

RUN set -xe \
  && find /usr/local -regex '/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf \
  && find /usr/local -name src | xargs -r find | grep -v '\.hrl$' | sort -r | xargs rm -rv || true \
  && find /usr/local -name src | xargs -r find | xargs rmdir -vp || true \
  && scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
  && scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
  && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" \
  && apk add --virtual $runDeps

## elixir_build
FROM erlang_minified as elixir_build

ENV ELIXIR_VER=1.7.3

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VER}.tar.gz" \
  && ELIXIR_DOWNLOAD_SHA256="c9beabd05e820ee83a56610cf2af3f34acf3b445c8fabdbe98894c886d2aa28e" \
  && curl -fSL -o elixir-src.tar.gz "$ELIXIR_DOWNLOAD_URL" \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && export ELIXIR_TOP="/usr/src/elixir_src_${ELIXIR_VER%%@*}" \
  && mkdir -vp $ELIXIR_TOP \
  && tar -xzf elixir-src.tar.gz -C $ELIXIR_TOP --strip-components=1 \
  && export ELIXIR_TOP="/usr/src/elixir_src_${ELIXIR_VER%%@*}" \
  && rm elixir-src.tar.gz && ls /usr/local/*\
  && ( cd $ELIXIR_TOP \
     && make -j$(getconf _NPROCESSORS_ONLN) \
     && make install ) \
  && rm -rf $ELIXIR_TOP

## elixir_minified
FROM elixir_build as elixir_minified

RUN set -xe \
  && find /usr/local/ -regex '/usr/local/lib/elixir/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf \
  && scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
  && scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
  && mix local.hex --force \
  && mix local.rebar --force

## stage
FROM deps as stage

ARG MIX_ENV="prod"

ENV APP_LOCATION="/app" \
    APP_NAME="kemisten" \
    MIX_ENV=${MIX_ENV}

## COPY --from=erlang_minified /usr/local /usr/local
COPY --from=elixir_minified /usr/local /opt/elixir

RUN set -xe \
  && rsync -a /opt/elixir/ /usr/local \
  && apk del .build-deps \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

## final_builder
FROM base as final_builder

COPY --from=stage /usr/local /usr/local

## app_build
FROM stage as app_build

COPY . ${APP_LOCATION}

RUN set -xe \
  && apk add --no-cache git \
  && cd ${APP_LOCATION} \
  && mix deps.get \
  && mix release --env=prod

FROM base

ARG MIX_ENV

ENV APP_LOCATION="/app" \
    APP_NAME="kemisten" \
    MIX_ENV=${MIX_ENV}

ENV PORT=80

COPY --from=app_build ${APP_LOCATION}/_build/${MIX_ENV}/rel/${APP_NAME} ${APP_LOCATION}

ENTRYPOINT ["/bin/bash", "-c", "/app/bin/${APP_NAME} foreground"]

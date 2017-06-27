
FROM menuan/elixir:3.6.0

ENV BUILD_MODE $MODE
RUN mkdir -p /app
COPY ./ /app

RUN cd /app && \
    rm -rf _build Dockerfile && \
    env BM=${BUILD_MODE} ./build.sh

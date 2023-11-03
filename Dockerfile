# https://hub.docker.com/layers/library/debian/12.2-slim/images/sha256-ea5ad531efe1ac11ff69395d032909baf423b8b88e9aade07e11b40b2e5a1338?context=explore
FROM debian:12.2-slim@sha256:ea5ad531efe1ac11ff69395d032909baf423b8b88e9aade07e11b40b2e5a1338

LABEL description="Build environment for bemanitools-mame-plugins"

RUN apt-get update && apt-get install -y \
    make \
    zip \
    gcc-mingw-w64-x86-64 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /bemanitools-mame-plugins
WORKDIR /bemanitools-mame-plugins

ENTRYPOINT [ \
    "/bin/bash", \
    "-c" , \
    "cd /bemanitools-mame-plugins && \
    make" ]
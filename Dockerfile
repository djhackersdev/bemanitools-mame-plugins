FROM fedora:31

LABEL description="Build environment for iidxio-mame-plugin"

RUN yum -y install \
    make \
    zip \
    mingw64-gcc

RUN mkdir /iidxio-mame-plugin
WORKDIR /iidxio-mame-plugin

# Order optimized for docker layer caching
COPY GNUmakefile GNUmakefile
COPY Module.mk Module.mk
COPY README.md README.md
COPY dist dist
COPY src src

# Building
RUN make

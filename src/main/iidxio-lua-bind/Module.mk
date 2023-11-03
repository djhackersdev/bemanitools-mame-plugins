dlls        += iidxio-lua-bind
imps		+= iidxio lua54

deplibs_iidxio-lua-bind  := \
    iidxio \
    lua54 \

ldflags_iidxio-lua-bind      := \

libs_iidxio-lua-bind         := \
    util \

src_iidxio-lua-bind          := \
    iidxio-lua-bind.c \

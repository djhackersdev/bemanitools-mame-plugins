dlls        += iidxio-lua-bind
imps		+= iidxio lua53

deplibs_iidxio-lua-bind  := \
    iidxio \
    lua53 \

ldflags_iidxio-lua-bind      := \

libs_iidxio-lua-bind         := \
    util \

src_iidxio-lua-bind          := \
    iidxio-lua-bind.c \

dlls        += ddrio-lua-bind
imps		+= ddrio lua54

deplibs_ddrio-lua-bind  := \
    ddrio \
    lua54 \

ldflags_ddrio-lua-bind      := \

libs_ddrio-lua-bind         := \
    util \

src_ddrio-lua-bind          := \
    ddrio-lua-bind.c \

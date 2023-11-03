#include <windows.h>
#include <stdio.h>

#include "bemanitools/ddrio.h"

#include "lua-5.3.6/lua.h"
#include "lua-5.3.6/lauxlib.h"

#include "util/log.h"
#include "util/thread.h"

static int ddr_io_lua_init(lua_State *L)
{
    uint32_t log_level;
    bool res;

    log_level = luaL_checknumber(L, 1);

    if (log_level > 4) {
        log_level = 4;
    }

    log_set_level(log_level);
    log_to_writer(log_writer_stdout, NULL);

    ddr_io_set_loggers(
        log_impl_misc, log_impl_info, log_impl_warning, log_impl_fatal);
    
    res = ddr_io_init(crt_thread_create, crt_thread_join, crt_thread_destroy);

    lua_pushboolean(L, res);

    return 1;
}

static int ddr_io_lua_fini(lua_State *L)
{
    ddr_io_fini();

    return 0;
}

static int ddr_io_lua_read_pad(lua_State *L)
{
    uint32_t pad;

    pad = ddr_io_read_pad();

    lua_pushnumber(L, pad);

    return 1;
}

static int ddr_io_lua_set_lights_extio(lua_State *L)
{
    uint32_t extio_lights;

    extio_lights = luaL_checknumber(L, 1);

    ddr_io_set_lights_extio(extio_lights);

    return 0;
}

static int ddr_io_lua_set_lights_p3io(lua_State *L)
{
    uint32_t p3io_lights;

    p3io_lights = luaL_checknumber(L, 1);

    ddr_io_set_lights_p3io(p3io_lights);

    return 0;
}

static int ddr_io_lua_set_lights_hdxs_panel(lua_State *L)
{
    uint32_t hdxs_lights;

    hdxs_lights = luaL_checknumber(L, 1);

    ddr_io_set_lights_hdxs_panel(hdxs_lights);

    return 0;
}

static int ddr_io_lua_set_lights_hdxs_rgb(lua_State *L)
{
    uint8_t idx;
    uint8_t r;
    uint8_t g;
    uint8_t b;

    idx = luaL_checknumber(L, 1);
    r = luaL_checknumber(L, 2);
    g = luaL_checknumber(L, 3);
    b = luaL_checknumber(L, 4);

    ddr_io_set_lights_hdxs_rgb(idx, r, g, b);

    return 0;
}

int luaopen_ddrio_lua_bind(lua_State *L)
{
    lua_pushcfunction(L, ddr_io_lua_init);
    lua_setglobal(L, "ddr_io_init");
    lua_pushcfunction(L, ddr_io_lua_fini);
    lua_setglobal(L, "ddr_io_fini");
    lua_pushcfunction(L, ddr_io_lua_read_pad);
    lua_setglobal(L, "ddr_io_read_pad");
    lua_pushcfunction(L, ddr_io_lua_set_lights_extio);
    lua_setglobal(L, "ddr_io_set_lights_extio");
    lua_pushcfunction(L, ddr_io_lua_set_lights_p3io);
    lua_setglobal(L, "ddr_io_set_lights_p3io");
    lua_pushcfunction(L, ddr_io_lua_set_lights_hdxs_panel);
    lua_setglobal(L, "ddr_io_set_lights_hdxs_panel");
    lua_pushcfunction(L, ddr_io_lua_set_lights_hdxs_rgb);
    lua_setglobal(L, "ddr_io_set_lights_hdxs_rgb");

    return 1;
}
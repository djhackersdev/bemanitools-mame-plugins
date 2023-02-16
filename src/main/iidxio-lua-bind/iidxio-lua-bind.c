#include <windows.h>
#include <stdio.h>

#include "bemanitools/iidxio.h"

#include "lua-5.3.6/lua.h"
#include "lua-5.3.6/lauxlib.h"

#include "util/log.h"
#include "util/thread.h"

static int iidx_io_lua_init(lua_State *L)
{
    bool res;

    log_to_writer(log_writer_stdout, NULL);

    iidx_io_set_loggers(
        log_impl_misc, log_impl_info, log_impl_warning, log_impl_fatal);
    
    res = iidx_io_init(crt_thread_create, crt_thread_join, crt_thread_destroy);

    lua_pushboolean(L, res);

    return 1;
}

static int iidx_io_lua_fini(lua_State *L)
{
    iidx_io_fini();

    return 0;
}

static int iidx_io_lua_ep1_set_deck_lights(lua_State *L)
{
    uint16_t deck_lights;

    deck_lights = luaL_checknumber(L, 1);

    iidx_io_ep1_set_deck_lights(deck_lights);

    return 0;
}

static int iidx_io_lua_ep1_set_panel_lights(lua_State *L)
{
    uint8_t panel_lights;

    panel_lights = luaL_checknumber(L, 1);

    iidx_io_ep1_set_panel_lights(panel_lights);

    return 0;
}

static int iidx_io_lua_ep1_set_top_lamps(lua_State *L)
{
    uint8_t top_lamps;

    top_lamps = luaL_checknumber(L, 1);

    iidx_io_ep1_set_top_lamps(top_lamps);

    return 0;
}

static int iidx_io_lua_ep1_set_top_neons(lua_State *L)
{
    bool neons;

    neons = luaL_checknumber(L, 1);

    iidx_io_ep1_set_top_neons(neons);

    return 0;
}

static int iidx_io_lua_ep1_send(lua_State *L)
{
    bool res;

    res = iidx_io_ep1_send();

    lua_pushboolean(L, res);

    return 1;
}

static int iidx_io_lua_ep2_recv(lua_State *L)
{
    bool res;

    res = iidx_io_ep2_recv();

    lua_pushboolean(L, res);

    return 1;
}

static int iidx_io_lua_ep2_get_turntable(lua_State *L)
{
    uint8_t player_no;
    uint8_t turntable;

    player_no = luaL_checknumber(L, 1);

    turntable = iidx_io_ep2_get_turntable(player_no);

    lua_pushnumber(L, turntable);

    return 1;
}

static int iidx_io_lua_ep2_get_slider(lua_State *L)
{
    uint8_t slider_no;
    uint8_t slider;

    slider_no = luaL_checknumber(L, 1);

    slider = iidx_io_ep2_get_slider(slider_no);

    lua_pushnumber(L, slider);

    return 1;
}

static int iidx_io_lua_ep2_get_sys(lua_State *L)
{
    uint8_t sys;

    sys = iidx_io_ep2_get_sys();

    lua_pushnumber(L, sys);

    return 1;
}

static int iidx_io_lua_ep2_get_panel(lua_State *L)
{
    uint8_t panel;

    panel = iidx_io_ep2_get_panel();

    lua_pushnumber(L, panel);

    return 1;
}

static int iidx_io_lua_ep2_get_keys(lua_State *L)
{
    uint16_t keys;

    keys = iidx_io_ep2_get_keys();

    lua_pushnumber(L, keys);

    return 1;
}

static int iidx_io_lua_ep3_write_16seg(lua_State *L)
{
    const char* text;
    bool res;

    text = luaL_checkstring(L, 1);

    res = iidx_io_ep3_write_16seg(text);

    lua_pushboolean(L, res);

    return 1;
}

int luaopen_iidxio_lua_bind(lua_State *L)
{
    lua_pushcfunction(L, iidx_io_lua_init);
    lua_setglobal(L, "iidxio_init");
    lua_pushcfunction(L, iidx_io_lua_fini);
    lua_setglobal(L, "iidxio_fini");
    lua_pushcfunction(L, iidx_io_lua_ep1_set_deck_lights);
    lua_setglobal(L, "iidxio_ep1_set_deck_lights");
    lua_pushcfunction(L, iidx_io_lua_ep1_set_panel_lights);
    lua_setglobal(L, "iidxio_ep1_set_panel_lights");
    lua_pushcfunction(L, iidx_io_lua_ep1_set_top_lamps);
    lua_setglobal(L, "iidxio_ep1_set_top_lamps");
    lua_pushcfunction(L, iidx_io_lua_ep1_set_top_neons);
    lua_setglobal(L, "iidxio_ep1_set_top_neons");
    lua_pushcfunction(L, iidx_io_lua_ep1_send);
    lua_setglobal(L, "iidxio_ep1_send");
    lua_pushcfunction(L, iidx_io_lua_ep2_recv);
    lua_setglobal(L, "iidxio_ep2_recv");
    lua_pushcfunction(L, iidx_io_lua_ep2_get_turntable);
    lua_setglobal(L, "iidxio_ep2_get_turntable");
    lua_pushcfunction(L, iidx_io_lua_ep2_get_slider);
    lua_setglobal(L, "iidxio_ep2_get_slider");
    lua_pushcfunction(L, iidx_io_lua_ep2_get_sys);
    lua_setglobal(L, "iidxio_ep2_get_sys");
    lua_pushcfunction(L, iidx_io_lua_ep2_get_panel);
    lua_setglobal(L, "iidxio_ep2_get_panel");
    lua_pushcfunction(L, iidx_io_lua_ep2_get_keys);
    lua_setglobal(L, "iidxio_ep2_get_keys");
    lua_pushcfunction(L, iidx_io_lua_ep3_write_16seg);
    lua_setglobal(L, "iidxio_ep3_write_16seg");

    return 1;
}
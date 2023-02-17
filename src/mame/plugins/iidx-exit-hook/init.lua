-- This follows the layout of MAME's plugin system, reference for this plugin:
-- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/plugins/autofire/init.lua
local exports = {
	name = 'iidx-exit-hook',
	version = '0.0.1',
	description = 'Plugin to enable exiting MAME by pressing the P1 Start + P2 Start + VEFX + Effect buttons for the twinkle system',
	license = 'Unlicensed',
	author = { name = 'icex2' }
}

local iidxio = exports

function iidxio.startplugin()
    local PANEL_P1_START_MASK = (1 << 0)
    local PANEL_P2_START_MASK = (1 << 1)
    local PANEL_VEFX_MASK = (1 << 2)
    local PANEL_EFFECT_MASK = (1 << 3)

    local cur_io_offset = 0

    local function is_bit_set(data, mask)
        return (data & mask) > 0
    end

    local function is_exit_button_combination_active(data)
        return 
            is_bit_set(data, PANEL_P1_START_MASK) and
            is_bit_set(data, PANEL_P2_START_MASK) and
            is_bit_set(data, PANEL_VEFX_MASK) and
            is_bit_set(data, PANEL_EFFECT_MASK)
    end

    local function twinkle_io_write(offset, data, mask)
        if offset == 0x1F220000 and mask == 0xFF0000 then
            local data_masked = (data & mask) >> 16

            cur_io_offset = data_masked
        end

        return data
    end

    local function twinkle_io_read(offset, data, mask)
        if offset == 0x1f220004 and mask == 0xff then
            local data_masked = data & mask

            -- "Panel" + operator inputs
            if cur_io_offset == 0x07 then
                -- Active low inputs
                data_masked = data_masked ~ 0xff

                if is_exit_button_combination_active(data_masked) then
                    print("Exit hook triggered")
                    manager.machine:exit()
                end

                return data_masked ~ 0xff
            end
        end

        return data
    end

    local function init()
        -- Heuristic to ensure this plugin only runs with bmiidx games
        -- This also blocks the plugin from running when mame is started in "UI mode"
        if not string.find(manager.machine.system.name, "bmiidx") then
            return
        end

        local memory = manager.machine.devices[":maincpu"].spaces["program"]

        -- Tap into relevant IO regions for dispatching data reads and writes to those data areas
        -- Key reference for callback functions registered here:
        -- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/src/mame/konami/twinkle.cpp
        callback_twinkle_io_write = memory:install_write_tap(0x1f220000, 0x1f220003, "twinkle_io_write", twinkle_io_write)
        callback_twinkle_io_read = memory:install_read_tap(0x1f220004, 0x1f220007, "twinkle_io_read", twinkle_io_read)
    end

    ---------------------------------------------------------------------------
    -- Main
    ---------------------------------------------------------------------------

    emu.register_start(init)
end

return exports
-- This follows the layout of MAME's plugin system, reference for this plugin:
-- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/plugins/autofire/init.lua
local exports = {
	name = 'ddrio',
	version = '0.0.1',
	description = 'Plugin to integrate the Bemanitools 5 ddrio API for IO handling into the ksys573 system',
	license = 'Unlicensed',
	author = { name = 'icex2' }
}

local ddrio = exports

function ddrio.startplugin()
    local is_initialized = false

    local callback_ksys573_jamma1_read = nil
    local callback_ksys573_jamma2_read = nil
    local callback_ksys573_jamma3_read = nil

    local callback_ksys573_dio_write_1_0 = nil
    local callback_ksys573_dio_write_3_7 = nil
    local callback_ksys573_dio_write_4 = nil
    local callback_ksys573_dio_write_5_2 = nil

    local memory = nil

    -----------------------------------------------------------------------------------------------

    local DDRIO_LOG_LEVEL_FATAL = 0
    local DDRIO_LOG_LEVEL_WARN = 1
    local DDRIO_LOG_LEVEL_INFO = 2
    local DDRIO_LOG_LEVEL_MISC = 3

    local CABINET_TEST_MASK = (1 << 10)
    local CABINET_SERVICE_MASK = (1 << 28)
    local CABINET_COIN_1_MASK = (1 << 24)
    local CABINET_COIN_2_MASK = (1 << 25)

    local STAGE_P1_UP_MASK = (1 << 10)
    local STAGE_P1_DOWN_MASK = (1 << 11)
    local STAGE_P1_LEFT_MASK = (1 << 8)
    local STAGE_P1_RIGHT_MASK = (1 << 9)

    local STAGE_P2_UP_MASK = (1 << 2)
    local STAGE_P2_DOWN_MASK = (1 << 3)
    local STAGE_P2_LEFT_MASK = (1 << 0)
    local STAGE_P2_RIGHT_MASK = (1 << 1)

    local CABINET_P1_LEFT_MASK = (1 << 13)
    local CABINET_P1_RIGHT_MASK = (1 << 14)
    local CABINET_P1_START_MASK = (1 << 15)

    local CABINET_P2_LEFT_MASK = (1 << 5)
    local CABINET_P2_RIGHT_MASK = (1 << 6) 
    local CABINET_P2_START_MASK = (1 << 7)

    local JAMMA1_INPUT_MASK = 
        CABINET_SERVICE_MASK |
        CABINET_COIN_1_MASK |
        CABINET_COIN_2_MASK

    local JAMMA2_INPUT_MASK = 
        STAGE_P1_UP_MASK |
        STAGE_P1_DOWN_MASK |
        STAGE_P1_LEFT_MASK |
        STAGE_P1_RIGHT_MASK |
        STAGE_P2_UP_MASK |
        STAGE_P2_DOWN_MASK |
        STAGE_P2_LEFT_MASK |
        STAGE_P2_RIGHT_MASK |
        CABINET_P1_LEFT_MASK |
        CABINET_P1_RIGHT_MASK |
        CABINET_P1_START_MASK |
        CABINET_P2_LEFT_MASK |
        CABINET_P2_RIGHT_MASK |
        CABINET_P2_START_MASK

    local JAMMA3_INPUT_MASK = 
        CABINET_TEST_MASK

    -----------------------------------------------------------------------------------------------

    local DDRIO_TEST_MASK = (1 << 4)
    local DDRIO_COIN_MASK = (1 << 5)
    local DDRIO_SERVICE_MASK = (1 << 6)

    local DDRIO_P1_UP_MASK = (1 << 17)
    local DDRIO_P1_DOWN_MASK = (1 << 18)
    local DDRIO_P1_LEFT_MASK = (1 << 19)
    local DDRIO_P1_RIGHT_MASK = (1 << 20)

    local DDRIO_P2_UP_MASK = (1 << 9)
    local DDRIO_P2_DOWN_MASK = (1 << 10)
    local DDRIO_P2_LEFT_MASK = (1 << 11)
    local DDRIO_P2_RIGHT_MASK = (1 << 12)

    local DDRIO_P1_START_MASK = (1 << 16)
    local DDRIO_P1_MENU_LEFT_MASK = (1 << 22)
    local DDRIO_P1_MENU_RIGHT_MASK = (1 << 23)

    local DDRIO_P2_START_MASK = (1 << 8)
    local DDRIO_P2_MENU_LEFT_MASK = (1 << 14)
    local DDRIO_P2_MENU_RIGHT_MASK = (1 << 15)

    local DDRIO_EXTIO_LIGHT_NEONS = (1 << 14)

    local DDRIO_EXTIO_LIGHT_P2_RIGHT = (1 << 19)
    local DDRIO_EXTIO_LIGHT_P2_LEFT = (1 << 20)
    local DDRIO_EXTIO_LIGHT_P2_DOWN = (1 << 21)
    local DDRIO_EXTIO_LIGHT_P2_UP = (1 << 22)

    local DDRIO_EXTIO_LIGHT_P1_RIGHT = (1 << 27)
    local DDRIO_EXTIO_LIGHT_P1_LEFT = (1 << 28)
    local DDRIO_EXTIO_LIGHT_P1_DOWN = (1 << 29)
    local DDRIO_EXTIO_LIGHT_P1_UP = (1 << 30)

    local DDRIO_P3IO_LIGHT_P1_MENU = (1 << 0)
    local DDRIO_P3IO_LIGHT_P2_MENU = (1 << 1)
    local DDRIO_P3IO_LIGHT_P2_LOWER_LAMP = (1 << 4)
    local DDRIO_P3IO_LIGHT_P2_UPPER_LAMP = (1 << 5)
    local DDRIO_P3IO_LIGHT_P1_LOWER_LAMP = (1 << 6)
    local DDRIO_P3IO_LIGHT_P1_UPPER_LAMP = (1 << 7)

    local ddrio_state_pad = 0
    local ddrio_state_p3io_light = 0
    local ddrio_state_extio_light = 0

    -----------------------------------------------------------------------------------------------

    local ksys573_dio_write_output_data = {0, 0, 0, 0, 0, 0, 0, 0}

    local STAGE_IO_STATE_IDLE = 0
    local STAGE_IO_STATE_INIT = 1

    local stageio_bit_mask =
    {
        0, 6, 2, 4,
        0, 4, 0, 4,
        0, 4, 0, 4,
        0, 4, 0, 4,
        0, 4, 0, 4,
        0, 4, 0, 6
    }

    -- Stage IO state to drive P1 and P2 dance stages
    local stageio_data_do = {0, 0}
    local stageio_data_clk = {0, 0}
    local stageio_data_shift = {0, 0}
    local stageio_data_state = {0, 0}
    local stageio_data_bit = {0, 0}

    local stageio_input_mask = 0xffffffff

    ------------------------------------------------------------------------------------------------

    -- MAME port mapping reference
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L3061
    local function ksys573_jamma1_read(offset, data, mask)
        if offset == 0x1f400004 and mask == 0xffff0000 then
            local data_buf = 0

            if ddrio_state_pad & DDRIO_SERVICE_MASK > 0 then
                data_buf = data_buf | CABINET_SERVICE_MASK
            end

            if ddrio_state_pad & DDRIO_COIN_MASK > 0 then
                data_buf = data_buf | CABINET_COIN_1_MASK
            end

            -- Inputs are active low
            data_buf = data_buf ~ JAMMA1_INPUT_MASK

            -- Merge in the other data as it contains flags that need to be
            -- passed on from emulation to make things work
            local merged_data = data_buf | (data & ~JAMMA1_INPUT_MASK)

            return merged_data & mask
        end

        return
    end

    -- MAME port mapping reference
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L3119
    local function ksys573_jamma2_read(offset, data, mask)
        if offset == 0x1f400008 and mask == 0xffff then
            local data_buf = 0

            -- The following assumes that the calls to the ddrio library are not yielding
            -- high latency/costly calls to any IO hardware
            -- Otherwise, MAME runs into significant performance issues resulting in music slowing
            -- down and speeding up or general stuttering of gameplay
            -- Why are we doing it this way then?
            -- If the ddrio backend is using actual real hardware, which does not have good polling
            -- performance, unfortunately, it needs to be polled to the max to ensure the inputs
            -- are as low latency as possible. This comes at the cost of (CPU) performance, so doing
            -- that asynchronously is highly adviced. The following calls are just swapping
            -- states in the backend, and therefore, are very low latency. Therefore, it is fine to
            -- keep calling them from memory reads/writes
            ddrio_state_pad = ddr_io_read_pad()

            if ddrio_state_pad & DDRIO_P1_UP_MASK > 0 then
                data_buf = data_buf | STAGE_P1_UP_MASK
            end

            if ddrio_state_pad & DDRIO_P1_DOWN_MASK > 0 then
                data_buf = data_buf | STAGE_P1_DOWN_MASK  
            end

            if ddrio_state_pad & DDRIO_P1_LEFT_MASK > 0 then
                data_buf = data_buf | STAGE_P1_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P1_RIGHT_MASK > 0 then
                data_buf = data_buf | STAGE_P1_RIGHT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_UP_MASK > 0 then
                data_buf = data_buf | STAGE_P2_UP_MASK    
            end

            if ddrio_state_pad & DDRIO_P2_DOWN_MASK > 0 then
                data_buf = data_buf | STAGE_P2_DOWN_MASK   
            end

            if ddrio_state_pad & DDRIO_P2_LEFT_MASK > 0 then
                data_buf = data_buf | STAGE_P2_LEFT_MASK 
            end

            if ddrio_state_pad & DDRIO_P2_RIGHT_MASK > 0 then
                data_buf = data_buf | STAGE_P2_RIGHT_MASK  
            end

            -----------------------------------------------------------

            if ddrio_state_pad & DDRIO_P1_START_MASK > 0 then
                data_buf = data_buf | CABINET_P1_START_MASK 
            end

            if ddrio_state_pad & DDRIO_P1_MENU_LEFT_MASK > 0 then
                data_buf = data_buf | CABINET_P1_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P1_MENU_RIGHT_MASK > 0 then
                data_buf = data_buf | CABINET_P1_RIGHT_MASK   
            end

            if ddrio_state_pad & DDRIO_P2_START_MASK > 0 then
                data_buf = data_buf | CABINET_P2_START_MASK    
            end

            if ddrio_state_pad & DDRIO_P2_MENU_LEFT_MASK > 0 then
                data_buf = data_buf | CABINET_P2_LEFT_MASK
            end

            if ddrio_state_pad & DDRIO_P2_MENU_RIGHT_MASK > 0 then
                data_buf = data_buf | CABINET_P2_RIGHT_MASK  
            end

            -- Apply stage mask based on what the digital IO reports
            -- This is required as it masks certain bits during various
            -- application stages, e.g. boot, for different features,
            -- e.g. cabinet/hardware type detection

            -- Inputs are active low
            data_buf = (data_buf ~ JAMMA2_INPUT_MASK) & stageio_input_mask

            -- Merge in the other data as it contains flags that need to be
            -- passed on from emulation to make things work
            local merged_data = data_buf | (data & ~JAMMA2_INPUT_MASK)

            return merged_data & mask
        end

        return
    end

    -- MAME port mapping reference
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L3137
    local function ksys573_jamma3_read(offset, data, mask)
        if offset == 0x1f40000c and mask == 0xffff then
            local data_buf = 0

            if ddrio_state_pad & DDRIO_TEST_MASK > 0 then
                data_buf = data_buf | CABINET_TEST_MASK
            end
            
            -- Inputs are active low
            data_buf = data_buf ~ JAMMA3_INPUT_MASK

            -- Merge in the other data as it contains flags that need to be
            -- passed on from emulation to make things work
            local merged_data = data_buf | (data & ~JAMMA3_INPUT_MASK)

            return merged_data & mask
        end

        return
    end

    -- MAME reference: void ddr_state::gn845pwbb_do_w( int offset, int data )
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L1426C7-L1426C7
    local function gn845pwbb_do_w(player_id, data)
        if data > 0 then
            stageio_data_do[player_id] = 0
        else
            stageio_data_do[player_id] = 1
        end
    end

    -- MAME reference: void ddr_state::gn845pwbb_clk_w( int offset, int data )
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L1431
    local function gn845pwbb_clk_w(player_id, data)
        local clk = 0
        
        if data > 0 then
            clk = 0
        else 
            clk = 1
        end

        if not (clk == stageio_data_clk[player_id]) then
            stageio_data_clk[player_id] = clk

            if clk > 0 then
                stageio_data_shift[player_id] = 
                    (stageio_data_shift[player_id] >> 1) | (stageio_data_do[player_id] << 12)

                if stageio_data_state[player_id] == STAGE_IO_STATE_IDLE then
                    if stageio_data_shift[player_id] == 0xc90 then
                        stageio_data_state[player_id] = STAGE_IO_STATE_INIT
                        stageio_data_bit[player_id] = 0

                        stageio_input_mask = 0xfffff9f9
                    end
                elseif stageio_data_state[player_id] == STAGE_IO_STATE_INIT then
                    stageio_data_bit[player_id] = stageio_data_bit[player_id] + 1

                    if stageio_data_bit[player_id] < 22 then
                        -- +1s to address lua array index start at 1
                        local a = ( ( ( ( ~0x06 ) | stageio_bit_mask[ stageio_data_bit[ 0 + 1 ] + 1 ] ) & 0xff ) << 8 );
                        local b = ( ( ( ( ~0x06 ) | stageio_bit_mask[ stageio_data_bit[ 1 + 1 ] + 1 ] ) & 0xff ) << 0 );
    
                        stageio_input_mask = 0xffff0000 | a | b;
                    else
                        stageio_data_bit[player_id] = 0
                        stageio_data_state[player_id] = STAGE_IO_STATE_IDLE

                        stageio_input_mask = 0xffffffff
                    end
                end
            end
        end
    end

    -- MAME reference: void ddr_state::ddr_output_callback(offs_t offset, uint8_t data)
    -- https://github.com/mamedev/mame/blob/1b25d752c2a37441e8bb7cf2de502d10f138010f/src/mame/konami/ksys573.cpp#L1484
    local function ksys573_dio_write_output_dispatch(offset, data)
        local bit_inverted = 0

        if data > 0 then
            bit_inverted = 0
        else
            bit_inverted = 1
        end

        local prev_ddrio_state_extio_light = ddrio_state_extio_light
        local prev_ddrio_state_p3io_light = ddrio_state_p3io_light

        -- Lamp P1 up arrow
        if offset == 0 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P1_UP
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P1_UP
            end

        -- Lamp P1 left arrow
        elseif offset == 1 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P1_LEFT
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P1_LEFT
            end

        -- Lamp P1 right arrow
        elseif offset == 2 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P1_RIGHT
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P1_RIGHT
            end

        -- Lamp P1 down arrow
        elseif offset == 3 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P1_DOWN
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P1_DOWN
            end

        -- gn845pwbb_do_w
        elseif offset == 4 then
            gn845pwbb_do_w(1, bit_inverted)

        -- gn845pwbb_clk_w
        elseif offset == 7 then
            gn845pwbb_clk_w(1, bit_inverted)

        -- Lamp P2 up arrow
        elseif offset == 8 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P2_UP
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P2_UP
            end

        -- Lamp P2 left arrow
        elseif offset == 9 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P2_LEFT
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P2_LEFT
            end

        -- Lamp P2 right arrow
        elseif offset == 10 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P2_RIGHT
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P2_RIGHT
            end

        -- Lamp P2 down arrow
        elseif offset == 11 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_P2_DOWN
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_P2_DOWN
            end

        -- gn845pwbb_do_w
        elseif offset == 12 then
            gn845pwbb_do_w(2, bit_inverted)

        -- gn845pwbb_clk_w
        elseif offset == 15 then
            gn845pwbb_clk_w(2, bit_inverted)

        -- Lamp P1 cabinet buttons
        elseif offset == 17 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P1_MENU
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P1_MENU
            end

        -- Lamp P2 cabinet buttons
        elseif offset == 18 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P2_MENU
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P2_MENU
            end

        -- Lamp cabinet P1 low
        elseif offset == 20 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P1_LOWER_LAMP
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P1_LOWER_LAMP
            end

        -- Lamp cabinet P2 low
        elseif offset == 21 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P2_LOWER_LAMP
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P2_LOWER_LAMP
            end
        
        -- Lamp cabinet P2 high
        elseif offset == 22 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P2_UPPER_LAMP
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P2_UPPER_LAMP
            end

        -- Lamp cabinet P1 high
        elseif offset == 23 then
            if bit_inverted > 0 then
                ddrio_state_p3io_light = ddrio_state_p3io_light | DDRIO_P3IO_LIGHT_P1_UPPER_LAMP
            else
                ddrio_state_p3io_light = ddrio_state_p3io_light & ~DDRIO_P3IO_LIGHT_P1_UPPER_LAMP
            end

        -- Cabinet woofer neons
        elseif offset == 28 then
            if bit_inverted > 0 then
                ddrio_state_extio_light = ddrio_state_extio_light | DDRIO_EXTIO_LIGHT_NEONS
            else
                ddrio_state_extio_light = ddrio_state_extio_light & ~DDRIO_EXTIO_LIGHT_NEONS
            end
        end

        -- The following assumes that the calls to the ddrio library are not yielding
        -- high latency/costly calls to any IO hardware
        -- Otherwise, MAME runs into significant performance issues resulting in music slowing
        -- down and speeding up or general stuttering of gameplay
        -- Why are we doing it this way then?
        -- If the ddrio backend is using actual real hardware, which does not have good polling
        -- performance, unfortunately, it needs to be polled to the max to ensure the inputs
        -- are as low latency as possible. This comes at the cost of (CPU) performance, so doing
        -- that asynchronously is highly adviced. The following calls are just swapping
        -- states in the backend, and therefore, are very low latency. Therefore, it is fine to
        -- keep calling them from memory reads/writes

        if not (prev_ddrio_state_extio_light == ddrio_state_extio_light) then
            ddr_io_set_lights_extio(ddrio_state_extio_light)
        end

        if not (prev_ddrio_state_p3io_light == ddrio_state_p3io_light) then
            ddr_io_set_lights_p3io(ddrio_state_p3io_light)
        end
    end

    -- MAME reference: void k573dio_device::output(int offset, uint16_t data)
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L444
    local function ksys573_dio_write_output(offset, data)
        data = (data >> 12) & 0x0f
        local shift = { 0, 2, 3, 1 }

        -- lua array offsets start at 1 =|
        array_offset = offset + 1

        for i = 0, 3, 1 do
            -- lua array offsets start at 1 =|
            local shift_array_offset = i + 1

            local oldbit = (ksys573_dio_write_output_data[array_offset] >> shift[shift_array_offset]) & 1
            local newbit = (data >> shift[shift_array_offset]) & 1
        
            if not (oldbit == newbit) then
                ksys573_dio_write_output_dispatch(4 * offset + i, newbit & 0xff)
            end
        end

        ksys573_dio_write_output_data[array_offset] = data;
    end

    -- MAME references: void k573dio_device::output_0_w(uint16_t data), void k573dio_device::output_1_w(uint16_t data)
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L371
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L376
    local function ksys573_dio_write_1_0(offset, data, mask)
        if offset == 0x1f6400e0 then
            if mask == 0xffff then
                ksys573_dio_write_output(1, data & 0xffff)
            elseif mask == 0xffff0000 then
                ksys573_dio_write_output(0, (data >> 16) & 0xffff)
            end
        end
    end

    -- MAME references: void k573dio_device::output_3_w(uint16_t data), void k573dio_device::output_7_w(uint16_t data)
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L376
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L381C1-L381C47
    local function ksys573_dio_write_3_7(offset, data, mask)
        if offset == 0x1f6400e4 then
            if mask == 0xffff then
                ksys573_dio_write_output(3, data & 0xffff)
            elseif mask == 0xffff0000 then
                ksys573_dio_write_output(7, (data >> 16) & 0xffff)
            end
        end
    end

    -- MAME references: void k573dio_device::output_4_w(uint16_t data)
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L428C1-L429C47
    local function ksys573_dio_write_4(offset, data, mask)
        if offset == 0x1f6400f8 then
            if mask == 0xffff0000 then
                ksys573_dio_write_output(4, (data >> 16) & 0xffff)
            end
        end
    end

    -- MAME references: void k573dio_device::output_5_w(uint16_t data), void k573dio_device::output_2_w(uint16_t data)
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L434
    -- https://github.com/mamedev/mame/blob/db964f13cf1065b378efcc4314e5e21dfd524e12/src/mame/konami/k573dio.cpp#L439
    local function ksys573_dio_write_5_2(offset, data, mask)
        if offset == 0x1f6400fc then
            if mask == 0xffff then
                ksys573_dio_write_output(5, data & 0xffff)
            elseif mask == 0xffff0000 then
                ksys573_dio_write_output(2, (data >> 16) & 0xffff)
            end
        end
    end

    local function init()
        -- Protect to init once because register_start is also called on machine reset
        if is_initialized then
            return
        end

        manager.machine:logerror(string.format("ddrio plugin called for machine '%s'", manager.machine.system.name))

        -- Heuristic to ensure this plugin only runs with ddr or ds (dancing stage) games
        if (not string.find(manager.machine.system.name, "ddr")) and (not string.find(manager.machine.system.name, "ds")) then
            return
        end

        local memory = manager.machine.devices[":maincpu"].spaces["program"]

        -- Tap into relevant IO regions for dispatching data reads and writes to those data areas
        -- Key reference for callback functions registered here:
        -- https://github.com/mamedev/mame/blob/9dbf099b651c8c48140db01059614e23d5bbdcb9/src/mame/konami/ksys573.cpp

        -- Inputs from JAMMA edge, pad inputs, cabinet buttons

        -- Leave out 0x1f400000 to 0x1f400003 which is jamma0 which are not used

        if callback_ksys573_jamma1_read == nil then
            callback_ksys573_jamma1_read = memory:install_read_tap(
                0x1f400004,
                0x1f400007,
                "ksys573_jamma1_read",
                ksys573_jamma1_read)
        else
            callback_ksys573_jamma1_read:reinstall()
        end

        if callback_ksys573_jamma2_read == nil then
            callback_ksys573_jamma2_read = memory:install_read_tap(
                0x1f400008,
                0x1f40000b,
                "ksys573_jamma2_read",
                ksys573_jamma2_read)
        else
            callback_ksys573_jamma2_read:reinstall()
        end

        if callback_ksys573_jamma3_read == nil then
            callback_ksys573_jamma3_read = memory:install_read_tap(
                0x1f40000c,
                0x1f40000f,
                "ksys573_jamma3_read",
                ksys573_jamma3_read)
        else
            callback_ksys573_jamma3_read:reinstall()
        end
        
        -- Outputs from digital IO, stage PCB and lights data
        -- Mame lua API requires to read 4 bytes, output registers are 2 bytes width each

        if callback_ksys573_dio_write_1_0 == nil then
            callback_ksys573_dio_write_1_0 = memory:install_write_tap(
                0x1f6400e0,
                0x1f6400e3,
                "ksys573_dio_write_1_0",
                ksys573_dio_write_1_0)
        else
            callback_ksys573_dio_write_1_0:reinstall()
        end

        if callback_ksys573_dio_write_3_7 == nil then
            callback_ksys573_dio_write_3_7 = memory:install_write_tap(
                0x1f6400e4,
                0x1f6400e7,
                "ksys573_dio_write_3_7",
                ksys573_dio_write_3_7)
        else
            callback_ksys573_dio_write_3_7:reinstall()
        end

        if callback_ksys573_dio_write_4 == nil then
            callback_ksys573_dio_write_4 = memory:install_write_tap(
                0x1f6400f8,
                0x1f6400fb,
                "ksys573_dio_write_4",
                ksys573_dio_write_4)
        else
            callback_ksys573_dio_write_4:reinstall()
        end

        if callback_ksys573_dio_write_5_2 == nil then
            callback_ksys573_dio_write_5_2 = memory:install_write_tap(
                0x1f6400fc,
                0x1f6400ff,
                "ksys573_dio_write_5_2",
                ksys573_dio_write_5_2)
        else
            callback_ksys573_dio_write_5_2:reinstall()
        end

        -- Loads native ddrio lua bindings c-library with ddrio bemanitools API glue code
        manager.machine:logerror("Loading ddrio_lua_bind.dll...")
  
        require("ddrio_lua_bind")

        manager.machine:logerror("Caling ddr_io_init...")

        if ddr_io_init(DDRIO_LOG_LEVEL_INFO) == false then
            manager.machine:logerror("ERROR initializing ddrio backend")
            return
        end

        -- Switch everything off and read inputs once to avoid random (input) noise
        ddr_io_set_lights_extio(0)
        ddr_io_set_lights_p3io(0)
        ddr_io_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        ddrio_state_pad = 0
        ddrio_state_p3io_light = 0
        ddrio_state_extio_light = 0
    
        ksys573_dio_write_output_data = {0, 0, 0, 0, 0, 0, 0, 0}

        stageio_input_mask = 0xffffffff

        is_initialized = true

        manager.machine:logerror("ddrio plugin initialized")
    end

    local function deinit()
        if not is_initialized then
            return
        end

        -- Switch everything off
        ddr_io_set_lights_extio(0)
        ddr_io_set_lights_p3io(0)
        ddr_io_set_lights_hdxs_panel(0)

        for i = 0, 0x0b, 1 do
            ddr_io_set_lights_hdxs_rgb(i, 0, 0, 0)
        end

        ddr_io_fini()

        is_initialized = false

        manager.machine:logerror("ddrio plugin de-initialized")
    end

    ---------------------------------------------------------------------------
    -- Main
    ---------------------------------------------------------------------------

    emu.register_start(init)
    emu.register_stop(deinit)
end

return exports
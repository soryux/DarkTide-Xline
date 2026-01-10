local mod = get_mod("Xline")

local OutlineSettings = nil
local breed_data = nil

local is_fully_loaded = false


local Unit_alive = Unit.alive
local Unit_local_position = Unit.local_position
local Vector3_distance_squared = Vector3.distance_squared
local table_insert = table.insert
local _G = _G

local table_clear = table.clear or function(t) 
    for k in pairs(t) do t[k] = nil end 
end

local to_add_vis_units = {}
local cached_local_player_unit = nil
local cached_player_pos = nil 
local check_timer = 0
local HEALTH_ALIVE = nil 

local _global_enabled = true
local _runtime_dist_sq = {}
local _cached_enable_state = {}

local function update_settings_cache()
    if not breed_data or not breed_data.units then return end
    
    table_clear(_cached_enable_state)
    table_clear(_runtime_dist_sq)
    
    for _, unit_list in pairs(breed_data.units) do
        for _, unit_info in ipairs(unit_list) do
            local id = unit_info.id
            local dist = mod:get("minion_" .. id .. "_dist") or unit_info.dist or 30
            _runtime_dist_sq[id] = dist * dist
            
            local is_enabled = mod:get("minion_" .. id .. "_enable")
            if is_enabled == nil then is_enabled = unit_info.enabled end
            _cached_enable_state[id] = is_enabled
        end
    end
end

local function create_visibility_check(breed_name)
    local default_dist_sq = 900 
    
    return function(unit)
        if not unit then return false end
        if not cached_player_pos then return false end
        if unit == cached_local_player_unit then return false end

        if not Unit_alive(unit) then return false end
        if HEALTH_ALIVE and not HEALTH_ALIVE[unit] then return false end

        local max_dist_sq = _runtime_dist_sq[breed_name] or default_dist_sq
        local u_pos = Unit_local_position(unit, 1)
        
        return Vector3_distance_squared(u_pos, cached_player_pos) < max_dist_sq
    end
end

local function is_in_game_session()
    return Managers.state and Managers.state.game_mode ~= nil
end

mod:hook(CLASS.UnitSpawnerManager, "_create_unit_extensions", function(func, self, world, unit, extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
    if not is_fully_loaded or not _global_enabled then
        return func(self, world, unit, extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
    end

    local new_extension_init_function = function(unit, config, ...)
        local r1, r2, r3, r4 = extension_init_function(unit, config, ...)
        
        pcall(function()
            if OutlineSettings then
                local breed = nil
                local has_outline = false
                
                local num_ext = config:num_extensions()
                for i = 1, num_ext do
                    local name, init_args = config:extension(i)
                    if name == "MinionUnitDataExtension" then
                        breed = init_args.breed
                    elseif name == "MinionOutlineExtension" then
                        has_outline = true
                    end
                end

                if breed and breed.name then
                    if not has_outline then
                        config:add("MinionOutlineExtension", { breed = breed })
                    end

                    if _cached_enable_state[breed.name] then
                        table_insert(to_add_vis_units, { unit = unit, breed_name = breed.name })
                    end
                end
            end
        end)

        return r1, r2, r3, r4
    end

    return func(self, world, unit, new_extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
end)

mod:hook(CLASS.OutlineSystem, "_check_global_visibility", function(func, self, ...)
    if is_fully_loaded and is_in_game_session() and _global_enabled then
        if self:_cinematic_active() then return false end
        return true
    end
    return func(self, ...)
end)

mod.on_setting_changed = function(setting_id)
    if setting_id == "global_enable" then
        _global_enabled = mod:get("global_enable")
    end

    if is_fully_loaded then
        update_settings_cache()

        if OutlineSettings and breed_data and breed_data.units then
            for _, unit_list in pairs(breed_data.units) do
                for _, unit_info in ipairs(unit_list) do
                    local breed_name = unit_info.id
                    local setting_key = "xline_" .. breed_name
                    
                    if OutlineSettings.MinionOutlineExtension[setting_key] then
                        local r = mod:get("minion_" .. breed_name .. "_r") or unit_info.r or 255
                        local g = mod:get("minion_" .. breed_name .. "_g") or unit_info.g or 255
                        local b = mod:get("minion_" .. breed_name .. "_b") or unit_info.b or 255
                        
                        OutlineSettings.MinionOutlineExtension[setting_key].color = { r/255, g/255, b/255 }
                    end
                end
            end
        end
    end
end

mod.on_all_mods_loaded = function()
    OutlineSettings = require("scripts/settings/outline/outline_settings")
    
    if _G.HEALTH_ALIVE then
        HEALTH_ALIVE = _G.HEALTH_ALIVE
    end

    local success, result = pcall(function() 
        return mod:io_dofile("Xline/scripts/mods/Xline/Xbreed")
    end)
    
    if success then
        breed_data = result
    else
        mod:info("Xbreed file load failed: " .. tostring(result))
    end

    _global_enabled = mod:get("global_enable")

    if OutlineSettings and breed_data then
        update_settings_cache()
        
        is_fully_loaded = true
        
        if breed_data.units then
            for _, unit_list in pairs(breed_data.units) do
                for _, unit_info in ipairs(unit_list) do
                    local breed_name = unit_info.id
                    
                    local r = mod:get("minion_" .. breed_name .. "_r") or unit_info.r or 255
                    local g = mod:get("minion_" .. breed_name .. "_g") or unit_info.g or 255
                    local b = mod:get("minion_" .. breed_name .. "_b") or unit_info.b or 255
                    
                    OutlineSettings.MinionOutlineExtension["xline_" .. breed_name] = {
                        priority = 100,
                        material_layers = { "minion_outline" },
                        color = { r/255, g/255, b/255 },
                        visibility_check = create_visibility_check(breed_name),
                    }
                end
            end
        end
    end
end

mod.update = function(dt)
    if not is_fully_loaded or not is_in_game_session() then 
        cached_local_player_unit = nil
        cached_player_pos = nil
        if #to_add_vis_units > 0 then table_clear(to_add_vis_units) end
        return 
    end

    check_timer = check_timer + dt
    if check_timer > 0.5 then
        check_timer = 0
        if Managers.player then
            local local_player = Managers.player:local_player(1)
            if local_player and local_player.player_unit and Unit_alive(local_player.player_unit) then
                cached_local_player_unit = local_player.player_unit
            else
                cached_local_player_unit = nil
            end
        end
    end

    if cached_local_player_unit and Unit_alive(cached_local_player_unit) then
        cached_player_pos = Unit_local_position(cached_local_player_unit, 1)
    else
        cached_player_pos = nil
    end

    if #to_add_vis_units > 0 then
        local extension_manager = Managers.state.extension
        if extension_manager then
            local outline_system = extension_manager:system("outline_system")
            if outline_system then
                for i = 1, #to_add_vis_units do
                    local data = to_add_vis_units[i]
                    local unit = data.unit
                    
                    local is_valid = true
                    if not unit or not Unit_alive(unit) then is_valid = false end
                    if is_valid and HEALTH_ALIVE and not HEALTH_ALIVE[unit] then is_valid = false end

                    if is_valid then
                        local outline_name = "xline_" .. data.breed_name
                        if OutlineSettings.MinionOutlineExtension[outline_name] then
                            pcall(function() 
                                outline_system:add_outline(unit, outline_name)
                            end)
                        end
                    end
                end
                table_clear(to_add_vis_units)
            end
        end
    end
end

mod.on_unload = function()
    is_fully_loaded = false
    cached_local_player_unit = nil
    cached_player_pos = nil
    HEALTH_ALIVE = nil
    table_clear(to_add_vis_units) 
    table_clear(_runtime_dist_sq) 
    table_clear(_cached_enable_state)
    
    if OutlineSettings and breed_data and breed_data.units then
        for _, unit_list in pairs(breed_data.units) do
            for _, unit_info in ipairs(unit_list) do
                if OutlineSettings.MinionOutlineExtension then
                    OutlineSettings.MinionOutlineExtension["xline_" .. unit_info.id] = nil
                end
            end
        end
    end
end

return mod
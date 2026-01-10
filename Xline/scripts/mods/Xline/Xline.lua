local mod = get_mod("Xline")
local OutlineSettings = require("scripts/settings/outline/outline_settings")
local breed_data = mod:io_dofile("Xline/scripts/mods/Xline/Xbreed")

local recover_override_settings = function() end
local override_settings = function() end
local to_add_vis_units = {}

local function iter_config(config, cb)
    for i = 1, config:num_extensions() do
        local name, init_args, remove_when_killed = config:extension(i)
        if cb(name, init_args, remove_when_killed) then
            break
        end
    end
end

mod:hook(CLASS.UnitSpawnerManager, "_create_unit_extensions", function(func, self, world, unit, extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
    override_settings()

    local new_extension_init_function = function(unit, config, ...)
        local res = extension_init_function(unit, config, ...)
        
        local has_outline = false
        local breed = nil

        iter_config(config, function(name, init_args)
            if name == "MinionUnitDataExtension" then
                breed = init_args.breed
                if has_outline then return true end
            elseif name == "MinionOutlineExtension" then
                has_outline = true
                if breed then return true end
            end
        end)

        if breed then
            if not has_outline then
                config:add("MinionOutlineExtension", {
                    breed = breed,
                })
            end

            if mod:get("global_enable") then
                local breed_name = breed.name
                if mod:get("minion_" .. breed_name .. "_enable") then
                    table.insert(to_add_vis_units, {
                        unit = unit,
                        breed_name = breed_name
                    })
                end
            end
        end

        return res
    end

    return func(self, world, unit, new_extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
end)

mod:hook(CLASS.OutlineSystem, "_check_global_visibility", function(func, self, ...)
    if mod:get("global_enable") then
        if self:_cinematic_active() then
            return false
        end
        return true
    end
    return func(self, ...)
end)

local function update_outlines(dt)
    if #to_add_vis_units == 0 then return end
    
    local extension_manager = Managers and Managers.state and Managers.state.extension
    local outline_system = extension_manager and extension_manager:system("outline_system")
    
    if not outline_system then return end

    while #to_add_vis_units > 0 do
        local data = table.remove(to_add_vis_units, 1)
        
        if data.unit and Unit.alive(data.unit) and HEALTH_ALIVE[data.unit] then
            local outline_name = "xline_" .. data.breed_name
            if OutlineSettings.MinionOutlineExtension[outline_name] then
                outline_system:add_outline(data.unit, outline_name)
            end
        end
    end
end

override_settings = function()
    local Vector3_distance_squared = Vector3.distance_squared
    local Unit_local_position = Unit.local_position

    if breed_data and breed_data.units then
        for category, unit_list in pairs(breed_data.units) do
            for _, unit_info in ipairs(unit_list) do
                local breed_name = unit_info.id
                

                local r = mod:get("minion_" .. breed_name .. "_r") or unit_info.r or 255
                local g = mod:get("minion_" .. breed_name .. "_g") or unit_info.g or 255
                local b = mod:get("minion_" .. breed_name .. "_b") or unit_info.b or 255
                local render_dist = mod:get("minion_" .. breed_name .. "_dist") or unit_info.dist or 30
                local MAX_DIST_SQ = render_dist * render_dist

                local outline_key = "xline_" .. breed_name

                local function check_distance_visibility(unit)
                    if not unit or not Unit.alive(unit) then return false end
                    if not HEALTH_ALIVE[unit] then return false end

                    local player_manager = Managers.player
                    if not player_manager then return false end
                    
                    local local_player = player_manager:local_player(1)
                    if not local_player then return false end
                    
                    local player_unit = local_player.player_unit
                    if not player_unit then return false end

                    local unit_pos = Unit_local_position(unit, 1)
                    local player_pos = Unit_local_position(player_unit, 1)
                    
                    return Vector3_distance_squared(unit_pos, player_pos) < MAX_DIST_SQ
                end

                OutlineSettings.MinionOutlineExtension[outline_key] = {
                    priority = 100,
                    material_layers = { "minion_outline" },
                    color = { r/255, g/255, b/255 },
                    visibility_check = check_distance_visibility,
                }
            end
        end
    end

    recover_override_settings = function()
        if breed_data and breed_data.units then
            for _, unit_list in pairs(breed_data.units) do
                for _, unit_info in ipairs(unit_list) do
                    OutlineSettings.MinionOutlineExtension["xline_" .. unit_info.id] = nil
                end
            end
        end
    end
end

mod.on_setting_changed = function()
    override_settings()
end

mod.update = function(dt)
    update_outlines(dt)
end

mod.on_unload = function()
    recover_override_settings()
end

override_settings()

return mod
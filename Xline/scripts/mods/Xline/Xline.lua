local mod = get_mod("Xline")

local OutlineSettings = nil
local breed_data = nil
local is_fully_loaded = false

-- 性能优化：本地化高频调用的函数
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

----------------------------------------------------------------
-- 核心逻辑函数
----------------------------------------------------------------

-- 预定义一个永远返回 false 的空函数，用于禁用状态，极省性能
local function hidden_visibility_check() 
    return false 
end

-- 基础可见性判断逻辑
local function create_visibility_check(breed_id)
    local default_dist_sq = 900 
    
    return function(unit)
        -- 既然已经进入这个函数，说明全局和单体开关都是开启的
        -- 核心防御：必须有玩家坐标参考且单位依然存活
        if not unit or not cached_player_pos then return false end
        if unit == cached_local_player_unit then return false end

        if not Unit_alive(unit) then return false end
        if HEALTH_ALIVE and not HEALTH_ALIVE[unit] then return false end

        local max_dist_sq = _runtime_dist_sq[breed_id] or default_dist_sq
        local u_pos = Unit_local_position(unit, 1)
        
        return Vector3_distance_squared(u_pos, cached_player_pos) < max_dist_sq
    end
end

-- 实时刷新配置：处理颜色、开关、距离
local function update_settings_cache()
    if not breed_data or not breed_data.units or not OutlineSettings then return end
    
    table_clear(_runtime_dist_sq)
    
    for _, unit_list in pairs(breed_data.units) do
        for _, unit_info in ipairs(unit_list) do
            local id = unit_info.id
            local template_name = "xline_" .. id
            local template = OutlineSettings.MinionOutlineExtension[template_name]
            
            -- 获取当前菜单配置
            local dist = mod:get("minion_" .. id .. "_dist") or unit_info.dist or 30
            _runtime_dist_sq[id] = dist * dist
            
            local is_enabled = mod:get("minion_" .. id .. "_enable")
            if is_enabled == nil then is_enabled = unit_info.enabled end
            
            if template then
                -- 1. 实时更新颜色 (直接改写模板表)
                local r = mod:get("minion_" .. id .. "_r") or unit_info.r or 255
                local g = mod:get("minion_" .. id .. "_g") or unit_info.g or 255
                local b = mod:get("minion_" .. id .. "_b") or unit_info.b or 255
                template.color = { r/255, g/255, b/255 }

                -- 2. 动态切换闭包：如果模组禁用或该单位禁用，直接指向空函数
                if not _global_enabled or not is_enabled then
                    template.visibility_check = hidden_visibility_check
                else
                    template.visibility_check = create_visibility_check(id)
                end
            end
        end
    end
end

local function is_in_game_session()
    return Managers.state and Managers.state.game_mode ~= nil
end

----------------------------------------------------------------
-- 安全挂钩 (Safe Hooks)
----------------------------------------------------------------

-- 1. 敌人生成拦截
if CLASS.UnitSpawnerManager then
    mod:hook(CLASS.UnitSpawnerManager, "_create_unit_extensions", function(func, self, world, unit, extension_init_function, ...)
        if not is_fully_loaded or not func then
            return func(self, world, unit, extension_init_function, ...)
        end

        local new_extension_init_function = function(u, config, ...)
            local r1, r2, r3, r4 = extension_init_function(u, config, ...)
            pcall(function()
                if OutlineSettings then
                    local breed = nil
                    local has_outline = false
                    local num_ext = config:num_extensions()
                    for i = 1, num_ext do
                        local name, init_args = config:extension(i)
                        if name == "MinionUnitDataExtension" then breed = init_args.breed
                        elseif name == "MinionOutlineExtension" then has_outline = true end
                    end
                    if breed and breed.name then
                        -- 如果该 breed 在配置列表里，确保它拥有轮廓扩展
                        local template_name = "xline_" .. breed.name
                        if OutlineSettings.MinionOutlineExtension[template_name] then
                            if not has_outline then config:add("MinionOutlineExtension", { breed = breed }) end
                            table_insert(to_add_vis_units, { unit = u, breed_name = breed.name })
                        end
                    end
                end
            end)
            return r1, r2, r3, r4
        end
        return func(self, world, unit, new_extension_init_function, ...)
    end)
end

-- 2. 全局可见性与稳定性修复
if CLASS.OutlineSystem then
    mod:hook(CLASS.OutlineSystem, "_check_global_visibility", function(func, self, ...)
        if is_fully_loaded and is_in_game_session() then
            if self:_cinematic_active() then return false end
            return true
        end
        return func(self, ...)
    end)
    
    mod:hook(CLASS.OutlineSystem, "on_remove_extension", function(orig, self, unit, extension_name)
        if self._unit_extension_data and self._unit_extension_data[unit] ~= nil then
            return orig(self, unit, extension_name)
        end
    end)
end

----------------------------------------------------------------
-- 生命周期与数据加载
----------------------------------------------------------------

-- 菜单设置变动回调
mod.on_setting_changed = function(setting_id)
    _global_enabled = mod:get("global_enable")
    if is_fully_loaded then 
        update_settings_cache() 
    end
end

mod.on_all_mods_loaded = function()
    OutlineSettings = require("scripts/settings/outline/outline_settings")
    if _G.HEALTH_ALIVE then HEALTH_ALIVE = _G.HEALTH_ALIVE end

    local success, result = pcall(function() 
        return mod:io_dofile("Xline/scripts/mods/Xline/Xbreed")
    end)
    
    if success then breed_data = result
    else mod:info("Xbreed file load failed: " .. tostring(result)) end

    _global_enabled = mod:get("global_enable")
    if OutlineSettings and breed_data and breed_data.units then
        -- 首次加载：初始化所有模板
        for _, unit_list in pairs(breed_data.units) do
            for _, unit_info in ipairs(unit_list) do
                local breed_name = unit_info.id
                OutlineSettings.MinionOutlineExtension["xline_" .. breed_name] = {
                    priority = 100,
                    material_layers = { "minion_outline" },
                    color = { 1, 1, 1 }, 
                    visibility_check = hidden_visibility_check,
                }
            end
        end
        update_settings_cache()
        is_fully_loaded = true
    end
end

mod.update = function(dt)
    if not is_fully_loaded or not is_in_game_session() then 
        cached_local_player_unit, cached_player_pos = nil, nil
        if #to_add_vis_units > 0 then table_clear(to_add_vis_units) end
        return 
    end

    -- 1. 定期更新玩家单位引用
    check_timer = check_timer + dt
    if check_timer > 0.5 then
        check_timer = 0
        if Managers.player then
            local lp = Managers.player:local_player(1)
            -- 核心修复：确保 unit 存在且存活
            cached_local_player_unit = (lp and lp.player_unit and Unit_alive(lp.player_unit)) and lp.player_unit or nil
        end
    end

    -- 2. 核心修复：获取坐标前进行二次验证，防止 UnitReference is not valid 崩溃
    if cached_local_player_unit and Unit_alive(cached_local_player_unit) then
        cached_player_pos = Unit_local_position(cached_local_player_unit, 1)
    else
        cached_player_pos = nil
    end

    -- 3. 将新生成的单位添加进 Outline 系统
    if #to_add_vis_units > 0 then
        local extension_manager = Managers.state.extension
        local outline_system = extension_manager and extension_manager:system("outline_system")
        if outline_system then
            for i = 1, #to_add_vis_units do
                local data = to_add_vis_units[i]
                local u = data.unit
                -- 核心修复：添加前验证单位有效性
                if u and Unit_alive(u) then
                    local name = "xline_" .. data.breed_name
                    if OutlineSettings.MinionOutlineExtension[name] then
                        pcall(function() outline_system:add_outline(u, name) end)
                    end
                end
            end
            table_clear(to_add_vis_units)
        end
    end
end

mod.on_unload = function()
    is_fully_loaded = false
    table_clear(to_add_vis_units) 
    if OutlineSettings and breed_data and breed_data.units then
        for _, unit_list in pairs(breed_data.units) do
            for _, unit_info in ipairs(unit_list) do
                if OutlineSettings.MinionOutlineExtension then OutlineSettings.MinionOutlineExtension["xline_" .. unit_info.id] = nil end
            end
        end
    end
end

return mod
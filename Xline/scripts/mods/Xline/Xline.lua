local mod = get_mod("Xline")

-- 变量占位
local OutlineSettings = nil
local breed_data = nil

-- 状态控制
local is_fully_loaded = false

-- 本地化高频函数 (LuaJIT 最佳实践：减少全局查找)
local Unit_alive = Unit.alive
local Unit_local_position = Unit.local_position
local Vector3_distance_squared = Vector3.distance_squared
local table_insert = table.insert
local table_remove = table.remove
local _G = _G

-- 数据缓存
local to_add_vis_units = {}
local cached_local_player_unit = nil
local cached_player_pos = nil -- 【新增】缓存每一帧玩家的坐标
local check_timer = 0

-- 【新增】缓存 HEALTH_ALIVE 表的引用，避免每次都去 _G 里找
local HEALTH_ALIVE = nil 

-- =========================================================
-- 1. 工具函数
-- =========================================================

local function is_in_game_session()
    return Managers.state and Managers.state.game_mode ~= nil
end

-- =========================================================
-- 2. 极致优化的可见性检查
-- =========================================================

-- 这个函数会在渲染线程被疯狂调用，必须最简！
local function create_visibility_check(max_dist_sq)
    return function(unit)
        -- 1. 基础检查
        if not unit or not Unit_alive(unit) then return false end
        
        -- 2. 快速失败：如果这一帧没缓存到玩家位置，直接不显示，等下一帧
        if not cached_player_pos then return false end
        
        -- 3. 排除玩家自己
        if unit == cached_local_player_unit then return false end
        
        -- 4. 存活检查 (直接使用本地缓存的表引用)
        if HEALTH_ALIVE and not HEALTH_ALIVE[unit] then return false end

        -- 5. 距离计算
        -- 玩家位置直接用缓存的 Vector3，省去了一次昂贵的 C++ 交互
        local u_pos = Unit_local_position(unit, 1)
        
        return Vector3_distance_squared(u_pos, cached_player_pos) < max_dist_sq
    end
end

-- =========================================================
-- 3. Hooks
-- =========================================================

mod:hook(CLASS.UnitSpawnerManager, "_create_unit_extensions", function(func, self, world, unit, extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
    -- 安全阀
    if not is_fully_loaded or not is_in_game_session() or not mod:get("global_enable") then
        return func(self, world, unit, extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
    end

    local new_extension_init_function = function(unit, config, ...)
        local res = extension_init_function(unit, config, ...)
        
        if not OutlineSettings then return res end

        local has_outline = false
        local breed = nil

        -- 快速遍历
        for i = 1, config:num_extensions() do
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
            
            -- 仅当设置开启时才加入队列
            if mod:get("minion_" .. breed.name .. "_enable") == true then
                table_insert(to_add_vis_units, { unit = unit, breed_name = breed.name })
            end
        end

        return res
    end

    return func(self, world, unit, new_extension_init_function, extension_unit_spawned_function_or_nil, game_object_data_or_session, ...)
end)

mod:hook(CLASS.OutlineSystem, "_check_global_visibility", function(func, self, ...)
    if is_fully_loaded and is_in_game_session() and mod:get("global_enable") then
        if self:_cinematic_active() then return false end
        return true
    end
    return func(self, ...)
end)

-- =========================================================
-- 4. 生命周期管理
-- =========================================================

mod.on_all_mods_loaded = function()
    OutlineSettings = require("scripts/settings/outline/outline_settings")
    
    -- 获取全局表引用
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

    if OutlineSettings and breed_data then
        is_fully_loaded = true
        
        -- 应用设置
        if breed_data.units then
            for _, unit_list in pairs(breed_data.units) do
                for _, unit_info in ipairs(unit_list) do
                    local breed_name = unit_info.id
                    -- 参数读取
                    local r = mod:get("minion_" .. breed_name .. "_r") or unit_info.r or 255
                    local g = mod:get("minion_" .. breed_name .. "_g") or unit_info.g or 255
                    local b = mod:get("minion_" .. breed_name .. "_b") or unit_info.b or 255
                    local dist = mod:get("minion_" .. breed_name .. "_dist") or unit_info.dist or 30
                    local max_dist_sq = dist * dist
                    
                    OutlineSettings.MinionOutlineExtension["xline_" .. breed_name] = {
                        priority = 100,
                        material_layers = { "minion_outline" },
                        color = { r/255, g/255, b/255 },
                        visibility_check = create_visibility_check(max_dist_sq),
                    }
                end
            end
        end
    end
end

mod.update = function(dt)
    -- 安全退出
    if not is_fully_loaded or not is_in_game_session() then 
        cached_local_player_unit = nil
        cached_player_pos = nil -- 清理位置缓存
        to_add_vis_units = {}
        return 
    end

    -- 1. 更新玩家单位引用 (低频，0.5秒一次)
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

    -- 2. 更新玩家位置缓存 (高频，每一帧必须更新)
    -- 这样所有敌人的 outline check 都不用自己去查位置了
    if cached_local_player_unit and Unit_alive(cached_local_player_unit) then
        cached_player_pos = Unit_local_position(cached_local_player_unit, 1)
    else
        cached_player_pos = nil
    end

    -- 3. 消费添加队列
    if #to_add_vis_units > 0 then
        local extension_manager = Managers.state.extension
        if extension_manager then
            local outline_system = extension_manager:system("outline_system")
            if outline_system then
                for i = #to_add_vis_units, 1, -1 do
                    local data = to_add_vis_units[i]
                    if data.unit and Unit_alive(data.unit) then
                        local outline_name = "xline_" .. data.breed_name
                        if OutlineSettings.MinionOutlineExtension[outline_name] then
                            outline_system:add_outline(data.unit, outline_name)
                        end
                    end
                    table_remove(to_add_vis_units, i)
                end
            end
        end
    end
end

mod.on_unload = function()
    is_fully_loaded = false
    cached_local_player_unit = nil
    cached_player_pos = nil
    HEALTH_ALIVE = nil
    to_add_vis_units = {}
    
    -- 清理注入
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
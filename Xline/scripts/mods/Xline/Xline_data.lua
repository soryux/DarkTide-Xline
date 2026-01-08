local mod = get_mod("Xline")
local minion_data = mod:io_dofile("Xline/scripts/mods/Xline/minion_data")

local category_order = {
    "控制型专家",
    "专家",
    "远程精英",
    "近战精英",
    "远程小兵",    
    "近战小兵",
    "怪物", 
}

local data = {
    name = "Xline",
    description = "动态轮廓显示",
    is_togglable = true, 
    options = {
        widgets = {
            {
                setting_id    = "global_enable",
                type          = "checkbox",
                default_value = true,
                title         = "开启",
            },
            {
                setting_id    = "render_distance",
                type          = "numeric",
                default_value = 30,
                range         = {10, 100},
                step_size_value = 5,
                title         = "显示距离 (米)",
            },
        }
    }
}

if minion_data and minion_data.names then
    for _, category_name in ipairs(category_order) do
        local breed_list = minion_data.names[category_name]

        if breed_list then
            local category_group = {
                setting_id = "group_" .. category_name,
                type = "group",
                title = category_name,
                sub_widgets = {}
            }

            for _, breed_name in ipairs(breed_list) do
                
                local final_title = ""
                
                if minion_data.display_name and minion_data.display_name[breed_name] then
                    local custom_name = minion_data.display_name[breed_name]
                    
                    
                    if string.find(custom_name, "^loc_") then
                        final_title = Localize(custom_name)
                    else
                        
                        final_title = custom_name
                    end
                else
                    
                    final_title = Localize("loc_breed_display_name_" .. breed_name)
                end
                local unit_widgets = {
                    setting_id = "unit_group_" .. breed_name,
                    type = "group",
                    title = final_title, 
                    sub_widgets = {
                        {
                            setting_id    = "minion_" .. breed_name .. "_enable",
                            type          = "checkbox",
                            title         = "启用",
                            default_value = false, 
                        },
                        {
                            setting_id      = "minion_" .. breed_name .. "_r",
                            title           = "颜色: 红 (R)",
                            type            = "numeric",
                            default_value   = 0,
                            range           = {0, 255},
                            decimals_number = 0,
                        },
                        {
                            setting_id      = "minion_" .. breed_name .. "_g",
                            title           = "颜色: 绿 (G)",
                            type            = "numeric",
                            default_value   = 0,
                            range           = {0, 255},
                            decimals_number = 0,
                        },
                        {
                            setting_id      = "minion_" .. breed_name .. "_b",
                            title           = "颜色: 蓝 (B)",
                            type            = "numeric",
                            default_value   = 0,
                            range           = {0, 255},
                            decimals_number = 0,
                        },
                    }
                }
                table.insert(category_group.sub_widgets, unit_widgets)
            end
            table.insert(data.options.widgets, category_group)
        end
    end
end

return data
local mod = get_mod("Xline")
local breed_file_path = "Xline/scripts/mods/Xline/Xbreed"
local loc_file_path = "Xline/scripts/mods/Xline/Xline_localization"

local breed_data = mod:io_dofile(breed_file_path)
local loc_data = mod:io_dofile(loc_file_path)

local function get_current_language()
    return Application.user_setting("language_id") or "en"
end

local current_lang = get_current_language()
local function safe_localize(key)
    if loc_data and loc_data[key] then
        if loc_data[key][current_lang] then
            return loc_data[key][current_lang]
        end
        if loc_data[key]["en"] then
            return loc_data[key]["en"]
        end
    end
    return key
end

local category_order = { "control_specialist", "specialist", "ranged_elite", "melee_elite", "ranged_minion", "melee_minion", "monster" }

local category_to_game_loc = {
    control_specialist = "loc_glossary_specialists_title",
    specialist = "loc_glossary_specialists_title",
    ranged_elite = "loc_glossary_elites_title",
    melee_elite = "loc_glossary_elites_title",
    ranged_minion = "loc_glossary_minions_title",
    melee_minion = "loc_glossary_minions_title",
    monster = "loc_glossary_monstrosities_title"
}

local data = {
    name = safe_localize("mod_name"),
    is_togglable = true, 
    options = {
        widgets = {
            { setting_id = "global_enable", type = "checkbox", default_value = true, title = "global_enable" },
        }
    }
}

if breed_data and breed_data.units then
    for _, category in ipairs(category_order) do
        local unit_list = breed_data.units[category]
        if unit_list then
            local game_loc_key = category_to_game_loc[category]
            local cat_title = Managers.localization and Managers.localization:localize(game_loc_key)
            
            if not cat_title or cat_title:find("<") or cat_title == "" then
                cat_title = safe_localize("cat_" .. category)
            end
            
            if not cat_title or cat_title:find("<") or cat_title == "" then
                cat_title = category:gsub("_", " "):upper()
            end

            local category_group = {
                setting_id = "group_" .. category,
                type = "group",
                title = cat_title,
                sub_widgets = {}
            }

            for _, unit_info in ipairs(unit_list) do
                local breed_name = unit_info.id
                local translate_key = unit_info.translate_key
                local display_name = Managers.localization and Managers.localization:localize("loc_breed_name_" .. breed_name)
                
                if not display_name or display_name:find("<") or display_name == "" then
                    display_name = Managers.localization and Managers.localization:localize("loc_breed_display_name_" .. breed_name)
                end

                if (not display_name or display_name:find("<") or display_name == "") and unit_info.comment then
                    display_name = unit_info.comment
                end

                if (not display_name or display_name:find("<") or display_name == "") and translate_key then
                    local localized = safe_localize(translate_key)

                    if localized ~= translate_key then
                        display_name = localized
                    end
                end

                if not display_name or display_name == "" or display_name:find("<") then
                    display_name = breed_name
                end

                table.insert(category_group.sub_widgets, {
                    setting_id = "minion_" .. breed_name .. "_group",
                    type = "group",
                    title = display_name,
                    sub_widgets = {
                        { setting_id = "minion_" .. breed_name .. "_enable", title = "unit_enable", type = "checkbox", default_value = unit_info.enabled },
                        { setting_id = "minion_" .. breed_name .. "_dist", title = "render_distance", type = "numeric", default_value = unit_info.dist or 30, range = {1, 100} },
                        { setting_id = "minion_" .. breed_name .. "_r", title = "color_r", type = "numeric", default_value = unit_info.r or 255, range = {0, 255} },
                        { setting_id = "minion_" .. breed_name .. "_g", title = "color_g", type = "numeric", default_value = unit_info.g or 255, range = {0, 255} },
                        { setting_id = "minion_" .. breed_name .. "_b", title = "color_b", type = "numeric", default_value = unit_info.b or 255, range = {0, 255} },
                    }
                })
            end
            table.insert(data.options.widgets, category_group)
        end
    end
end

return data
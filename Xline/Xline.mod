return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`Xline` encountered an error loading the Darktide Mod Framework.")
        new_mod("Xline", {
            mod_script       = "Xline/scripts/mods/Xline/Xline",
            mod_data         = "Xline/scripts/mods/Xline/Xline_data",
            mod_localization = "Xline/scripts/mods/Xline/Xline_localization",
        })
    end,
    packages = {},
}
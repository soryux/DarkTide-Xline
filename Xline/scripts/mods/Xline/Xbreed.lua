local m = {
	units = {}
}

-- ==================== 控制专家 ====================
m.units.control_specialist = {
	{ id = "chaos_hound",              translate_key = "translate_chaos_hound",              r=255, g=255, b=0,   dist=30, enabled=true, comment = "瘟疫猎犬" },
	{ id = "chaos_hound_mutator",      translate_key = "translate_chaos_hound_mutator",      r=255, g=255, b=0,   dist=30, enabled=true, comment = "脆皮猎犬 (狩猎场)" },
	{ id = "cultist_mutant",           translate_key = "translate_cultist_mutant",           r=255, g=255, b=0,   dist=30, enabled=true, comment = "变种人" },
	{ id = "cultist_mutant_mutator",   translate_key = "translate_cultist_mutant_mutator",   r=255, g=255, b=0,   dist=30, enabled=true, comment = "变种人 (特殊波次)" },
	{ id = "renegade_netgunner",       translate_key = "translate_renegade_netgunner",       r=255, g=255, b=0,   dist=30, enabled=true, comment = "血痂陷阱手" },
}

-- ==================== 输出专家 ====================
m.units.specialist = {
	{ id = "chaos_poxwalker_bomber",   translate_key = "translate_chaos_poxwalker_bomber",   r=0, g=255, b=0, dist=30, enabled=true, comment = "瘟疫爆破手" },
	{ id = "renegade_grenadier",       translate_key = "translate_renegade_grenadier",       r=0, g=255, b=0, dist=100, enabled=true, comment = "血痂轰炸者" },
	{ id = "cultist_grenadier",        translate_key = "translate_cultist_grenadier",        r=0, g=255, b=0, dist=100, enabled=true, comment = "渣滓剧毒轰炸者" },
	{ id = "renegade_sniper",          translate_key = "translate_renegade_sniper",          r=0, g=255, b=0, dist=100, enabled=true, comment = "血痂狙击手" },
	{ id = "renegade_flamer",          translate_key = "translate_renegade_flamer",          r=255, g=120, b=120, dist=30, enabled=true, comment = "血痂火焰兵" },
	{ id = "cultist_flamer",           translate_key = "translate_cultist_flamer",           r=255, g=120, b=120, dist=30, enabled=true, comment = "渣滓剧毒火焰兵" },
}

-- ==================== 远程精英 ====================
m.units.ranged_elite = {
	{ id = "cultist_gunner",           translate_key = "translate_cultist_gunner",           r=255, g=90,  b=150, dist=50, enabled=true, comment = "渣滓炮手" },
	{ id = "renegade_gunner",          translate_key = "translate_renegade_gunner",          r=255, g=90,  b=150, dist=50, enabled=true, comment = "血痂炮手" },
	{ id = "cultist_shocktrooper",     translate_key = "translate_cultist_shocktrooper",     r=255, g=90,  b=150, dist=35, enabled=true, comment = "渣滓霰弹枪手" },
	{ id = "renegade_shocktrooper",    translate_key = "translate_renegade_shocktrooper",    r=255, g=90,  b=150, dist=35, enabled=true, comment = "血痂霰弹枪手" },
	{ id = "chaos_ogryn_gunner",       translate_key = "translate_chaos_ogryn_gunner",       r=255, g=90,  b=150, dist=50, enabled=true, comment = "收割者" },
	{ id = "renegade_plasma_gunner",   translate_key = "translate_renegade_plasma_gunner",   r=255, g=90,  b=150, dist=50, enabled=true, comment = "血痂炮手 (等离子)" },
}

-- ==================== 近战精英 ====================
m.units.melee_elite = {
	{ id = "cultist_berzerker",        translate_key = "translate_cultist_berzerker",        r=0,   g=255, b=255, dist=20, enabled=false, comment = "渣滓狂暴者" },
	{ id = "renegade_berzerker",       translate_key = "translate_renegade_berzerker",       r=0,   g=255, b=255, dist=20, enabled=false, comment = "血痂狂暴者" },
	{ id = "renegade_executor",        translate_key = "translate_renegade_executor",        r=0,   g=255, b=255, dist=20, enabled=false, comment = "血痂重锤兵" },
	{ id = "chaos_ogryn_bulwark",      translate_key = "translate_chaos_ogryn_bulwark",      r=255, g=0,   b=0,   dist=30, enabled=false, comment = "盾卫" },
	{ id = "chaos_ogryn_executor",     translate_key = "translate_chaos_ogryn_executor",     r=255, g=0,   b=0,   dist=30, enabled=false, comment = "粉碎者" },
}

-- ==================== 远程杂兵 ====================
m.units.ranged_minion = {
	{ id = "renegade_assault",         translate_key = "translate_renegade_assault",         r=255, g=90,  b=150, dist=30, enabled=true, comment = "血痂潜行者" },
	{ id = "cultist_assault",          translate_key = "translate_cultist_assault",          r=255, g=90,  b=150, dist=30, enabled=true, comment = "渣滓潜行者" },
	{ id = "renegade_rifleman",        translate_key = "translate_renegade_rifleman",        r=255, g=90,  b=150, dist=30, enabled=true, comment = "血痂步枪手" },
}

-- ==================== 近战杂兵 ====================
m.units.melee_minion = {
	{ id = "chaos_newly_infected",     translate_key = "translate_chaos_newly_infected",     r=100, g=100, b=100, dist=15, enabled=false, comment = "呻吟者" },
	{ id = "chaos_poxwalker",          translate_key = "translate_chaos_poxwalker",          r=100, g=100, b=100, dist=15, enabled=false, comment = "瘟疫行者" },
	{ id = "cultist_melee",            translate_key = "translate_cultist_melee",            r=100, g=100, b=100, dist=15, enabled=false, comment = "渣滓格斗兵" },
	{ id = "renegade_melee",           translate_key = "translate_renegade_melee",           r=100, g=100, b=100, dist=15, enabled=false, comment = "血痂格斗兵" },
	{ id = "chaos_lesser_mutated_poxwalker", translate_key = "translate_lesser_mutated_poxwalker", r=100, g=100, b=100, dist=15, enabled=false, comment = "变异瘟疫行者" },
	{ id = "chaos_mutated_poxwalker",  translate_key = "translate_mutated_poxwalker",        r=100, g=100, b=100, dist=15, enabled=false, comment = "触手瘟疫行者" },
}

-- ==================== Boss  ====================
m.units.monster = {
	{ id = "chaos_beast_of_nurgle",    translate_key = "translate_chaos_beast_of_nurgle",    r=255, g=0,   b=255, dist=50, enabled=false, comment = "纳垢兽" },
	{ id = "chaos_daemonhost",         translate_key = "translate_chaos_daemonhost",         r=255, g=255, b=0, dist=100, enabled=true, comment = "恶魔宿主" },
	{ id = "chaos_spawn",              translate_key = "translate_chaos_spawn",              r=255, g=0,   b=255, dist=50, enabled=false, comment = "混沌魔物" },
	{ id = "chaos_plague_ogryn",       translate_key = "translate_chaos_plague_ogryn",       r=255, g=0,   b=255, dist=50, enabled=false, comment = "瘟疫欧格林" },
	{ id = "chaos_plague_ogryn_sprayer", translate_key = "translate_chaos_plague_ogryn_sprayer", r=255, g=0,   b=255, dist=50, enabled=false, comment = "毒素欧格林" },
	{ id = "renegade_captain",         translate_key = "translate_renegade_captain",         r=255, g=0,   b=255, dist=50, enabled=false, comment = "血痂头目" },
}


return m



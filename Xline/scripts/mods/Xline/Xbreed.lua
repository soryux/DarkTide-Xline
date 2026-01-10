local m = {
	units = {}
}

-- ==================== 控制专家 ====================
m.units.control_specialist = {
	{ id = "chaos_hound",              translate_key = "translate_chaos_hound",              r=255, g=255, b=0,   dist=30, enabled=true }, -- 猎犬
	{ id = "chaos_hound_mutator",      translate_key = "translate_chaos_hound_mutator",      r=255, g=255, b=0,   dist=30, enabled=true }, -- 脆皮猎犬
	{ id = "cultist_mutant",           translate_key = "translate_cultist_mutant",           r=255, g=255, b=0,   dist=30, enabled=true }, -- 变种人
	{ id = "cultist_mutant_mutator",   translate_key = "translate_cultist_mutant_mutator",   r=255, g=255, b=0,   dist=30, enabled=true }, -- 脆皮变种人
	{ id = "renegade_netgunner",       translate_key = "translate_renegade_netgunner",       r=255, g=255, b=0,   dist=30, enabled=true }, -- 网子手
}

-- ==================== 输出专家 ( ====================
m.units.specialist = {
	{ id = "chaos_poxwalker_bomber",   translate_key = "translate_chaos_poxwalker_bomber",   r=100, g=255, b=100, dist=30, enabled=true }, -- 自爆者
	{ id = "renegade_grenadier",       translate_key = "translate_renegade_grenadier",       r=100, g=255, b=100, dist=50, enabled=true }, -- 血痂投弹手 
	{ id = "cultist_grenadier",        translate_key = "translate_cultist_grenadier",        r=100, g=255, b=100, dist=50, enabled=true }, -- 渣滓投弹手 
	{ id = "renegade_sniper",          translate_key = "translate_renegade_sniper",          r=255, g=255, b=255, dist=50, enabled=true }, -- 狙击手
	{ id = "renegade_flamer",          translate_key = "translate_renegade_flamer",          r=255, g=120, b=120, dist=30, enabled=true }, -- 血痂喷火兵
	{ id = "cultist_flamer",           translate_key = "translate_cultist_flamer",           r=255, g=120, b=120, dist=30, enabled=true }, -- 渣滓喷火兵
}

-- ==================== 远程精英 ====================
m.units.ranged_elite = {
	{ id = "cultist_gunner",           translate_key = "translate_cultist_gunner",           r=255, g=90,  b=150, dist=30, enabled=true }, -- 渣滓枪手
	{ id = "renegade_gunner",          translate_key = "translate_renegade_gunner",          r=255, g=90,  b=150, dist=30, enabled=true }, -- 血痂枪手
	{ id = "cultist_shocktrooper",     translate_key = "translate_cultist_shocktrooper",     r=255, g=90,  b=150, dist=30, enabled=true }, -- 渣滓散弹枪手
	{ id = "renegade_shocktrooper",    translate_key = "translate_renegade_shocktrooper",    r=255, g=90,  b=150, dist=30, enabled=true }, -- 血痂散弹枪手
	{ id = "chaos_ogryn_gunner",       translate_key = "translate_chaos_ogryn_gunner",       r=255, g=90,  b=150, dist=30, enabled=true }, -- 收割者 (欧格林枪手)
	{ id = "renegade_plasma_gunner",   translate_key = "translate_renegade_plasma_gunner",   r=255, g=90,  b=150, dist=30, enabled=true }, -- 等离子枪手
}

-- ==================== 近战精英 ====================
m.units.melee_elite = {
	{ id = "cultist_berzerker",        translate_key = "translate_cultist_berzerker",        r=0,   g=255, b=255, dist=20, enabled=false }, -- 渣滓狂信徒
	{ id = "renegade_berzerker",       translate_key = "translate_renegade_berzerker",       r=0,   g=255, b=255, dist=20, enabled=false }, -- 血痂狂信徒 (双斧)
	{ id = "renegade_executor",        translate_key = "translate_renegade_executor",        r=0,   g=255, b=255, dist=20, enabled=false }, -- 血痂狂信徒 (大剑)
	{ id = "chaos_ogryn_bulwark",      translate_key = "translate_chaos_ogryn_bulwark",      r=255, g=0,   b=0,   dist=30, enabled=false }, -- 持盾欧格林
	{ id = "chaos_ogryn_executor",     translate_key = "translate_chaos_ogryn_executor",     r=255, g=0,   b=0,   dist=30, enabled=false }, -- 粉碎者
}

-- ==================== 远程杂兵 ====================
m.units.ranged_minion = {
	{ id = "renegade_assault",         translate_key = "translate_renegade_assault",         r=255, g=90,  b=150, dist=30, enabled=true }, -- 血痂突击兵 (已改30)
	{ id = "cultist_assault",          translate_key = "translate_cultist_assault",          r=255, g=90,  b=150, dist=30, enabled=true }, -- 渣滓突击兵 (已改30)
	{ id = "renegade_rifleman",        translate_key = "translate_renegade_rifleman",        r=255, g=90,  b=150, dist=30, enabled=true }, -- 血痂步枪手 (已改30)
}

-- ==================== 近战杂兵 ====================
m.units.melee_minion = {
	{ id = "chaos_newly_infected",     translate_key = "translate_chaos_newly_infected",     r=100, g=100, b=100, dist=15, enabled=false }, -- 呻吟者
	{ id = "chaos_poxwalker",          translate_key = "translate_chaos_poxwalker",          r=100, g=100, b=100, dist=15, enabled=false }, -- 瘟疫行者
	{ id = "cultist_melee",            translate_key = "translate_cultist_melee",            r=100, g=100, b=100, dist=15, enabled=false }, -- 渣滓近战兵
	{ id = "renegade_melee",           translate_key = "translate_renegade_melee",           r=100, g=100, b=100, dist=15, enabled=false }, -- 血痂近战兵
	{ id = "chaos_lesser_mutated_poxwalker", translate_key = "translate_lesser_mutated_poxwalker", r=100, g=100, b=100, dist=15, enabled=false }, -- 弱变异行者
	{ id = "chaos_mutated_poxwalker",  translate_key = "translate_mutated_poxwalker",        r=100, g=100, b=100, dist=15, enabled=false }, -- 强变异行者
}

-- ==================== 怪物 & Boss  ====================
m.units.monster = {
	{ id = "chaos_beast_of_nurgle",    translate_key = "translate_chaos_beast_of_nurgle",    r=255, g=0,   b=255, dist=50, enabled=false }, -- 纳垢兽
	{ id = "chaos_daemonhost",         translate_key = "translate_chaos_daemonhost",         r=255, g=0,   b=255, dist=50, enabled=false }, -- 恶魔宿主
	{ id = "chaos_spawn",              translate_key = "translate_chaos_spawn",              r=255, g=0,   b=255, dist=50, enabled=false }, -- 混沌卵
	{ id = "chaos_plague_ogryn",       translate_key = "translate_chaos_plague_ogryn",       r=255, g=0,   b=255, dist=50, enabled=false }, -- 瘟疫欧格林
	{ id = "chaos_plague_ogryn_sprayer", translate_key = "translate_chaos_plague_ogryn_sprayer", r=255, g=0,   b=255, dist=50, enabled=false }, -- 瘟疫欧格林 (喷射型)
	{ id = "renegade_captain",         translate_key = "translate_renegade_captain",         r=255, g=0,   b=255, dist=50, enabled=false }, -- 叛军上尉
}

return m
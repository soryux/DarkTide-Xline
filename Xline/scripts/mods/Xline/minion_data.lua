local m = {
	names = {}
}

m.names.近战小兵 = {
	"chaos_newly_infected",
	"chaos_poxwalker",
	"cultist_melee",
	"renegade_melee",
	"chaos_lesser_mutated_poxwalker",--会发光的小兵，混沌次级变异瘟疫行者
	"chaos_mutated_poxwalker",--会发光的小兵，混沌变异瘟疫行者
}

m.names.远程小兵 = {
	"cultist_assault",
	"renegade_assault",
	"renegade_rifleman",
}

m.names.近战精英= {
	"cultist_berzerker",
	"renegade_berzerker",
	"renegade_executor",
	"chaos_ogryn_bulwark",
	"chaos_ogryn_executor",
}

m.names.怪物= {
	"chaos_beast_of_nurgle",
	"chaos_daemonhost",
	"chaos_spawn",
	"chaos_plague_ogryn",
	"chaos_plague_ogryn_sprayer",
	"renegade_captain",
}

m.names.专家 = {
	"chaos_poxwalker_bomber",--自爆
	"renegade_grenadier",--火雷
	"cultist_grenadier",--毒雷-tou
	"renegade_sniper", --狙击
	"renegade_flamer",--喷火兵-tou
	"cultist_flamer",--喷毒哥-tou
}

m.names.控制型专家 = {
	"chaos_hound",--狗
	"chaos_hound_mutator",
	"cultist_mutant", --牛
	"renegade_netgunner",  --网子哥
}

m.names.远程精英 = {
	"cultist_gunner",
	"renegade_gunner",
	"cultist_shocktrooper",
	"renegade_shocktrooper",
	"chaos_ogryn_gunner",
	"renegade_plasma_gunner",--等离子哥
}

m.display_name = {
	chaos_hound_mutator = "脆皮猎犬",
	chaos_plague_ogryn = "loc_breed_display_name_chaos_plage_ogryn",
}

return m
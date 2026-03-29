/datum/map_template/ruin/oshan
	ruin_type = ZTRAIT_OSHAN_MINING
	prefix = "_maps/RandomRuins/OshanRuins/"
	default_area = /area/ocean/generated

/datum/map_template/ruin/oshan/vent
	name = "Ore Vent"
	id = "ore_vent_o"
	description = "A vent that spews out ore. Seems to be a natural phenomenon."
	suffix = "oshan_surface_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE

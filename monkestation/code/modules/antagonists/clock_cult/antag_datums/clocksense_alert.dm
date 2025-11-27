//clock cult
/atom/movable/screen/alert/clockwork/clocksense
	name = "The Ark of the Clockwork Justicar"
	desc = "Shows infomation about the Ark of the Clockwork Justicar"
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "clockinfo"
	alerttooltipstyle = "clockwork"
	///The static info we use so we only have to actually update our data once each tick
	var/static/static_desc

/atom/movable/screen/alert/clockwork/clocksense/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(!static_desc)
		static_desc = get_static_desc()
	desc = static_desc
	if(!GLOB.ratvar_risen)
		START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/clockwork/clocksense/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/clockwork/clocksense/process()
	if(GLOB.ratvar_risen)
		desc = "<b>RATVAR HAS RISEN.<b>"
		return PROCESS_KILL

	var/static/last_process_tick
	if(!last_process_tick || world.time - last_process_tick > 1 SECOND)
		static_desc = get_static_desc()
		last_process_tick = world.time
	desc = static_desc

/atom/movable/screen/alert/clockwork/clocksense/proc/get_static_desc()
	if(GLOB.ratvar_risen)
		return "<b>RATVAR HAS RISEN.<b>"

	var/new_desc = "Stored Power - <b>[display_power(SSthe_ark.clock_power, FALSE)]</b>.<br>"
	new_desc += "Stored Vitality - <b>[GLOB.clock_vitality]</b>.<br>"
	new_desc += "Passive power access - <b>[SSthe_ark.passive_power]</b>.<br>"
	if(!GLOB.main_clock_cult)
		return

	new_desc += "We current have [length(GLOB.main_clock_cult.human_servants)] human servants out of [GLOB.main_clock_cult.max_human_servants] maximum human servants, \
			 as well as [length(GLOB.main_clock_cult.members)] servants all together.<br>"

	if(GLOB.clock_ark?.charging_for)
		new_desc += "The Ark will open in [600 - GLOB.clock_ark.charging_for] seconds!<br>"
		return //we dont care about anchoring crystals at this point

	var/static/list/cached_valid_areas
	if(length(cached_valid_areas) != length(SSthe_ark.valid_crystal_areas)) //using length due to the cache being area names and not areas themselves
		cached_valid_areas = list()
		for(var/area/added_area in SSthe_ark.valid_crystal_areas)
			cached_valid_areas += SSthe_ark.valid_crystal_areas[added_area]
	new_desc += "Anchoring Crystals can be summoned in [english_list(cached_valid_areas)].<br>"

	var/crystal_diff = ANCHORING_CRYSTALS_TO_SUMMON - length(SSthe_ark.anchoring_crystals)
	if(crystal_diff > 0)
		new_desc += "We must summon [crystal_diff] more Anchoring Crystal[crystal_diff > 1 ? "s" : ""] before the ark may open.<br>"
	return new_desc

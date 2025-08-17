GLOBAL_LIST_INIT_TYPED(bb_gear, /datum/bb_gear, init_bb_gear())

/datum/bb_gear
	var/name
	var/desc
	var/spawn_path
	var/preview_path
	var/player_minimum
	var/static/list/icon/cached_previews

/datum/bb_gear/proc/summon(mob/living/summoner, datum/team/brother_team/team)
	podspawn(list(
		"target" = get_turf(summoner),
		"style" = STYLE_SYNDICATE,
		"spawn" = spawn_path
	))

/datum/bb_gear/proc/is_available()
	if(player_minimum && (player_minimum > SSgamemode.get_correct_popcount()))
		return FALSE
	return TRUE

/datum/bb_gear/proc/preview() as /mutable_appearance
	if(LAZYACCESS(cached_previews, type))
		return cached_previews[type]
	var/preview_source = preview_path || spawn_path
	if(ispath(preview_source))
		var/obj/thingymajig = new preview_source(null)
		. = copy_appearance_filter_overlays(thingymajig.appearance, recursion = 1)
		qdel(thingymajig)
		LAZYSET(cached_previews, type, .)

/datum/bb_gear/proc/operator""()
	return "[name || type]"

/proc/init_bb_gear()
	. = list()
	for(var/datum/bb_gear/gear as anything in subtypesof(/datum/bb_gear))
		var/name = gear::name
		if(istext(name))
			.[name] = new gear

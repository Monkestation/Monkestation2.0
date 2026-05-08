#define DESIRED_AREAS_PER_TC_PER_MINUTE 30
#define DESIRED_AREAS_PER_THREAT_PER_MINUTE 4
#define MINUTE_MULT 0.167 //based on how many times we fire, currently 1/6 as we fire 6 times per minute
#define TC_PER_MINUTE_PER_REPRESENTATION 0.05
#define REP_PER_MINUTE_PER_REPRESENTATION 0.5
#define PAINTED_TILES_PER_REP 40
PROCESSING_SUBSYSTEM_DEF(gangs)
	name = "Gangs"
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_HIBERNATE
	wait = 10 SECONDS
	runlevels = RUNLEVEL_GAME
	///assoc list of areas with values of amounts to multiply their rewards by
	var/list/gang_area_multipliers
	///list of all gangs
	var/list/all_gangs
	///assoc list of gangs keyed to their tag
	var/alist/all_gangs_by_tag
	///assoc list of stored rep for a gang
	var/list/cached_extra_rep
	///assoc list of gang tags keyed to the area they are in
	var/alist/gang_tags_by_area
	///List of all possible gang tags
	var/list/all_gang_tags
	///List of remaining paint colors
	var/list/possible_gang_colors
	///assoc list of gang outfit items with key values of how much representation they provide
	var/alist/gang_outfits = alist() //starts as a list so we dont need to init the entire SS for a single peice of clothing getting spawned

/datum/controller/subsystem/processing/gangs/PreInit()
	. = ..()
	hibernate_checks += NAMEOF(src, all_gangs_by_tag)

/datum/controller/subsystem/processing/gangs/Initialize()
	initialized = TRUE
	all_gangs = list()
	all_gangs_by_tag = alist()
	cached_extra_rep = list()
	gang_tags_by_area = alist()
	//19 possible tags, you really shouldnt need more then this
	all_gang_tags = list(
		"Omni",
		"Newton",
		"Clandestine",
		"Prima",
		"Zero-G",
		"Osiron",
		"Psyke",
		"Diablo",
		"Blasto",
		"North",
		"Donk",
		"Sleeping Carp",
		"Gene",
		"Cyber",
		"Tunnel",
		"Sirius",
		"Waffle",
		"Max",
		"Gib",
	)

	//19 colors, as to match the amount of tags, you should avoid particularly light shades and colors as they dont show up well
	possible_gang_colors = list(
		COLOR_GOLD,
		COLOR_SYNDIE_RED,
		COLOR_MAROON,
		COLOR_ALMOST_BLACK,
		COLOR_CARP_RIFT_RED,
		COLOR_OLIVE,
		COLOR_VIBRANT_LIME,
		COLOR_CHRISTMAS_GREEN,
		COLOR_CYAN,
		COLOR_BLUE,
		COLOR_TEAL,
		COLOR_AMETHYST,
		COLOR_LIGHT_PINK,
		COLOR_PURPLE,
		COLOR_MAGENTA,
		COLOR_STRONG_VIOLET,
		COLOR_MOSTLY_PURE_ORANGE,
		COLOR_MODERATE_BLUE,
		COLOR_SOFT_RED,
	)

	RegisterSignal(SSticker, COMSIG_TICKER_DECLARE_ROUND_END, PROC_REF(calculate_painted_tiles))
	gang_area_multipliers = list(
	/area/station/command = 2,
	/area/station/security = 2,
	/area/station/ai_monitored = 2,
	/area/station/maintenance = 0.5,
	)
	for(var/area in gang_area_multipliers)
		var/mult = gang_area_multipliers[area]
		for(var/type in typesof(area))
			gang_area_multipliers[type] = mult * MINUTE_MULT

/datum/controller/subsystem/processing/gangs/fire(resumed)
	if(!initialized) //we hibernate so this wont get called until we are needed
		Initialize()

	var/static/log_cooldown
	if(!log_cooldown)
		log_cooldown = world.time + 5 MINUTES

	var/list/given_rewards = list()
	for(var/datum/team/gang/gang_team in all_gangs)
		var/list/temp = list("tc" = gang_team.passive_tc * MINUTE_MULT, "rep" = 0)
		given_rewards[gang_team] = temp
		var/tc_pointer = &temp["tc"] //cant wait to find out this is actually slower then just accessing key value each time because BYOND is magical
		var/rep_pointer = &temp["rep"]
		var/tc_mult = TC_PER_MINUTE_PER_REPRESENTATION * MINUTE_MULT
		var/rep_mult = REP_PER_MINUTE_PER_REPRESENTATION * MINUTE_MULT
		for(var/datum/antagonist/gang_member/member in gang_team.member_datums)
			*tc_pointer += member.total_representation * tc_mult
			*rep_pointer += member.total_representation * rep_mult

	for(var/area, owner in GLOB.gang_controlled_areas) //might want to use this to give gangs a printout of their controlled areas
		var/list/rewards = given_rewards[owner]
		var/area_mult = gang_area_multipliers[area] || MINUTE_MULT
		//note these values assume we are running on time, might be able to make these be based on SPT
		rewards["tc"] += area_mult / DESIRED_AREAS_PER_TC_PER_MINUTE
		rewards["rep"] += area_mult / DESIRED_AREAS_PER_THREAT_PER_MINUTE

	for(var/datum/team/gang/gang_team in given_rewards)
		var/rep_value = given_rewards[gang_team]["rep"] + (cached_extra_rep[gang_team] || 0)
		var/rounded_rep_value = round(rep_value, 0.1)
		cached_extra_rep[gang_team] = rep_value - rounded_rep_value

		gang_team.unallocated_tc = round((gang_team.unallocated_tc + given_rewards[gang_team]["tc"]), 0.001)
		gang_team.rep = round(rounded_rep_value + gang_team.rep, 0.1)

	for(var/datum/team/gang/gang_datum in all_gangs)
		gang_datum.update_handler_rep()

	//if this ends up being kept the code for this can be improved
	if(world.time >= log_cooldown)
		log_cooldown = world.time + 5 MINUTES
		var/text = "gang_rep_values: "
		for(var/datum/team/gang/g in all_gangs)
			text += "[g.name]: [g.rep] "
		text += "at: [DisplayTimeText(world.time)]"
		log_game(text)

///Calculate and give out the rep for painted tiles, called at round end
/datum/controller/subsystem/processing/gangs/proc/calculate_painted_tiles()
	var/list/datum/team/gang/gangs_by_color = list()
	for(var/datum/team/gang/gang_team in SSgangs.all_gangs)
		gangs_by_color[gang_team.gang_color] = gang_team

	for(var/turf/station_turf in GLOB.station_turfs)
		gangs_by_color[station_turf.atom_colours?[WASHABLE_COLOUR_PRIORITY]]?.painted_tiles++

	for(var/datum/team/gang/gang_team in all_gangs)
		gang_team.rep += gang_team.painted_tiles % PAINTED_TILES_PER_REP

///Call to add a piece of clothing to gang_outfits
/datum/controller/subsystem/processing/gangs/proc/register_gang_clothing(obj/item/clothing/registered, value = 1)
	gang_outfits[registered] = value
	RegisterSignal(registered, COMSIG_QDELETING, PROC_REF(gang_clothing_destroyed))

/datum/controller/subsystem/processing/gangs/proc/gang_clothing_destroyed(obj/item/clothing/destroyed)
	SIGNAL_HANDLER
	UnregisterSignal(destroyed, COMSIG_QDELETING)
	gang_outfits -= destroyed

#undef DESIRED_AREAS_PER_TC_PER_MINUTE
#undef DESIRED_AREAS_PER_THREAT_PER_MINUTE
#undef MINUTE_MULT
#undef TC_PER_MINUTE_PER_REPRESENTATION
#undef REP_PER_MINUTE_PER_REPRESENTATION
#undef PAINTED_TILES_PER_REP

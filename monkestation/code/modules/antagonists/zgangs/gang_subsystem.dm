#define DESIRED_AREAS_PER_TC_PER_MINUTE 20
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
	///alist of gangs keyed to their color
	var/alist/gangs_by_color
	///alist of all areas that have gang paint in them
	var/alist/gang_painted_areas

/datum/controller/subsystem/processing/gangs/PreInit()
	. = ..()
	hibernate_checks += NAMEOF(src, all_gangs_by_tag)

/datum/controller/subsystem/processing/gangs/Initialize()
	initialized = TRUE
	all_gangs = list()
	all_gangs_by_tag = alist()
	cached_extra_rep = list()
	gang_tags_by_area = alist()
	gangs_by_color = alist()
	gang_painted_areas = alist()
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

	//give rewards for gang representation
	var/alist/given_rewards = alist()
	for(var/datum/team/gang/gang_team in all_gangs)
		var/alist/temp = alist("tc" = gang_team.passive_tc * MINUTE_MULT, "rep" = 0)
		given_rewards[gang_team] = temp
		var/tc_pointer = &temp["tc"] //cant wait to find out this is actually slower then just accessing key value each time because BYOND is magical
		var/rep_pointer = &temp["rep"]
		var/tc_mult = TC_PER_MINUTE_PER_REPRESENTATION * MINUTE_MULT
		var/rep_mult = REP_PER_MINUTE_PER_REPRESENTATION * MINUTE_MULT
		for(var/datum/antagonist/gang_member/member in gang_team.member_datums)
			*tc_pointer += member.total_representation * tc_mult
			*rep_pointer += member.total_representation * rep_mult

	//give rewards for claimed areas
	var/list/temp_shuffle = shuffle(all_gangs) //tiebreaker, because whoever is iterated over first will win
	for(var/area/painted_area in gang_painted_areas)
		var/datum/team/gang/winner
		var/current_highscore = 0
		for(var/datum/team/gang/paint_gang in temp_shuffle)
			var/tile_amount = length(paint_gang.paint_by_area[painted_area])
			if(tile_amount && tile_amount > current_highscore)
				winner = paint_gang
				current_highscore = tile_amount
		given_rewards[winner]["rep"] += (gang_area_multipliers[painted_area] || MINUTE_MULT) / DESIRED_AREAS_PER_THREAT_PER_MINUTE

	//give rewards for tagged areas
	for(var/area, area_tag in gang_tags_by_area) //might want to use this to give gangs a printout of their controlled areas
		var/obj/effect/decal/cleanable/crayon/gang/typed_tag = area_tag
		var/datum/team/gang/owner = typed_tag.gang_owner
		var/list/rewards = given_rewards[owner]
		//note these values assume we are running on time, might be able to make these be based on SPT
		rewards["tc"] += (gang_area_multipliers[area] || MINUTE_MULT) / DESIRED_AREAS_PER_TC_PER_MINUTE

	//actually hand out the rewards
	for(var/datum/team/gang/gang_team in given_rewards)
		var/rep_value = given_rewards[gang_team]["rep"] + (cached_extra_rep[gang_team] || 0)
		var/rounded_rep_value = round(rep_value, 0.1)
		cached_extra_rep[gang_team] = rep_value - rounded_rep_value

		gang_team.unallocated_tc = round((gang_team.unallocated_tc + given_rewards[gang_team]["tc"]), 0.001)
		gang_team.rep = round(rounded_rep_value + gang_team.rep, 0.1)
		gang_team.update_handler_rep()

	//if this ends up being kept the code for this can be improved
	if(world.time >= log_cooldown)
		log_cooldown = world.time + 5 MINUTES
		var/text = "gang_rep_values: "
		for(var/datum/team/gang/g in all_gangs)
			text += "[g.name]: [g.rep] "
		text += "at: [DisplayTimeText(world.time)]"
		log_traitor(text)

///Apply paint to an atom, if passed a non mob or turf atom then we target that atoms turf
///Stacks is for the painted status effect if we are applying to a mob
/datum/controller/subsystem/processing/gangs/proc/paint_atom(atom/target, color, stacks = 1)
	if(!color)
		return FALSE

	if(ismob(target))
		return paint_mob(target, color, stacks)

	if(!isturf(target))
		target = get_turf(target)
	return paint_turf(target, color)

///Apply paint of the passed color to a turf, then claim it for the gang of that color
/datum/controller/subsystem/processing/gangs/proc/paint_turf(turf/target, color)
	if(!isturf(target) || (isgroundlessturf(target) && !GET_TURF_BELOW(target)))
		return FALSE

	. = target
	var/obj/effect/decal/paint_splatter/splatter = locate() in target
	if(splatter)
		var/old_color = splatter.paint_color
		splatter.paint_color = color
		splatter.creation_timestamp = world.time
		splatter.new_state(FALSE)
		if(old_color == color) //even if its the same color we still want to apply overlays for the adjacent tiles
			return

		gang_lose_splatter(splatter, gangs_by_color[old_color])
	else
		splatter = new(target, color)

	var/datum/team/gang/owner = gangs_by_color[color]
	if(!owner)
		return

	owner.RegisterSignal(splatter, COMSIG_QDELETING, TYPE_PROC_REF(/datum/team/gang, splatter_destroyed))
	owner.RegisterSignal(target, COMSIG_PAINT_SPLATTER_UPDATE, TYPE_PROC_REF(/datum/team/gang, splatter_update))
	owner.RegisterSignal(splatter, COMSIG_EXIT_AREA, TYPE_PROC_REF(/datum/team/gang, splatter_exited_area))
	var/area/splatter_area = get_area(splatter)
	var/list/paint_list = owner.paint_by_area[splatter_area]
	if(paint_list)
		paint_list += splatter
	else
		owner.paint_by_area[splatter_area] = list(splatter)
		if(!gang_painted_areas[splatter_area])
			gang_painted_areas[splatter_area] = 1
		else
			gang_painted_areas[splatter_area] += 1

/datum/controller/subsystem/processing/gangs/proc/paint_mob(mob/living/target, color, stacks = 1)
	if(!istype(target))
		return FALSE

	var/datum/antagonist/gang_member/gang_target = IS_GANGMEMBER(target)
	if(gang_target.gang_team?.gang_color == color)
		return FALSE
	. = target
	target.apply_status_effect(/datum/status_effect/painted, stacks)

/datum/controller/subsystem/processing/gangs/proc/gang_lose_splatter(obj/effect/decal/paint_splatter/lost, datum/team/gang/loser, transferring = FALSE)
	if(!loser)
		return

	loser.UnregisterSignal(lost, list(COMSIG_QDELETING, COMSIG_EXIT_AREA))
	loser.UnregisterSignal(get_turf(lost), COMSIG_PAINT_SPLATTER_UPDATE)
	var/area/lost_area = get_area(lost)
	var/list/paint_list = loser.paint_by_area[lost_area]
	if(!paint_list)
		return

	paint_list -= lost
	if(length(paint_list))
		return

	loser.paint_by_area -= lost_area
	gang_painted_areas[lost_area] -= 1
	if(!transferring && gang_painted_areas[lost_area] <= 0)
		gang_painted_areas -= lost_area

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

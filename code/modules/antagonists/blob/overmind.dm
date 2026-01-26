///If we have this many nodes we will be announced, anti stealth blob measure
#define NODES_TO_ANNOUNCE 3
//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs) //complete list of all blob tiles made.
GLOBAL_LIST_EMPTY(overminds)
GLOBAL_LIST_EMPTY(blob_nodes)

/mob/eye/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/eyemob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	see_invisible = SEE_INVISIBLE_LIVING
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	// Vivid blue green, would be cool to make this change with strain
	lighting_cutoff_red = 0
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 20
	hud_type = /datum/hud/blob_overmind
	///Ref to our core structure
	var/obj/structure/blob/special/node/blob_core
	///How many points do we have, used for building and attacking
	var/blob_points = 0
	///The maximum amount of points we can have
	var/max_blob_points = OVERMIND_MAX_POINTS_DEFAULT
	///Used for tracking the attacking/expanding cooldown
	var/last_attack = 0
	///How many free rerolls do we have left
	var/free_strain_rerolls = OVERMIND_STARTING_REROLLS
	///Time since we last rerolled, used to give free rerolls
	var/last_reroll_time = 0
	///If the blob needs nodes near by to place resource and factory blobs
	var/nodes_required = TRUE
	///Have we placed our core yet
	var/placed = FALSE
	///Minimum amount of time before you can place your core
	var/manualplace_min_time = OVERMIND_STARTING_MIN_PLACE_TIME
	///Amount of time you have before your core will be force played in a random spot
	var/autoplace_max_time = OVERMIND_STARTING_AUTO_PLACE_TIME
	///Are we currently rerolling
	var/rerolling = FALSE

	///Ref to our team
	var/datum/team/blob/antag_team
	///The list of strains the blob can reroll for.
	var/list/strain_choices

/mob/eye/blob/Initialize(mapload, starting_points = OVERMIND_STARTING_POINTS, datum/team/blob/blob_team)
	antag_team = blob_team || new /datum/team/blob()
	mind_initialize() //this adds our antag datum, which requires
	antag_team.add_member(mind) //this must be called right after init however needs mind to be initialized
	ADD_TRAIT(src, TRAIT_BLOB_ALLY, INNATE_TRAIT)
	validate_location()
	blob_points = starting_points
	manualplace_min_time += world.time
	autoplace_max_time += world.time
	GLOB.overminds += src
	var/is_lesser = istype(src, /mob/eye/blob/lesser)
	var/new_name = "[is_lesser ? "Lesser " : null][initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	color = antag_team.blobstrain.complementary_color
	if(blob_core)
		blob_core.update_appearance()

	. = ..()
	if(!is_lesser)
		START_PROCESSING(SSobj, src)
	GLOB.blob_telepathy_mobs |= src

/mob/eye/blob/Destroy()
	antag_team?.remove_member(mind)
	if(antag_team.main_overmind == src)
		antag_team.main_overmind_death()
	GLOB.overminds -= src
	QDEL_LIST_ASSOC_VAL(strain_choices)
	STOP_PROCESSING(SSobj, src)
	GLOB.blob_telepathy_mobs -= src
	return ..()

/mob/eye/blob/proc/validate_location()
	var/turf/our_turf = get_turf(src)
	if(is_valid_turf(our_turf))
		return

	if(LAZYLEN(GLOB.blobstart))
		for(var/turf/start as anything in shuffle(GLOB.blobstart))
			if(is_valid_turf(start))
				our_turf = start
				break
	else // no blob starts so look for an alternate
		for(var/i in 1 to 16)
			var/turf/picked_safe = find_safe_turf()
			if(is_valid_turf(picked_safe))
				our_turf = picked_safe
				break

	if(!our_turf)
		CRASH("No blobspawnpoints and blob spawned in nullspace.")
	forceMove(our_turf)

/mob/eye/blob/proc/update_strain(had_strain = FALSE)
	if(had_strain)
		to_chat(src, span_notice("Your strain is now: <b><font color=\"[antag_team.blobstrain.color]\">[antag_team.blobstrain.name]</b></font>!"))
		to_chat(src, span_notice("The <b><font color=\"[antag_team.blobstrain.color]\">[antag_team.blobstrain.name]</b></font> strain [antag_team.blobstrain.description]"))
		if(antag_team.blobstrain.effectdesc)
			to_chat(src, span_notice("The <b><font color=\"[antag_team.blobstrain.color]\">[antag_team.blobstrain.name]</b></font> strain [antag_team.blobstrain.effectdesc]"))
	SEND_SIGNAL(src, COMSIG_BLOB_SELECTED_STRAIN, antag_team.blobstrain)

/mob/eye/blob/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	if(placed) // The blob can't expand vertically (yet)
		return FALSE
	. = ..()
	if(!.)
		return
	var/turf/target_turf = .
	if(!is_valid_turf(target_turf)) // Allows unplaced blobs to travel through station z-levels
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(src, span_warning("Your destination is invalid. Move somewhere else and try again."))
		return null

/mob/eye/blob/proc/is_valid_turf(turf/tile)
	var/area/area = get_area(tile)
	if((area && !(area.area_flags & BLOBS_ALLOWED)) || !tile || !is_station_level(tile.z) || isgroundlessturf(tile))
		return FALSE
	return TRUE

/mob/eye/blob/process()
	if(!blob_core)
		if(!placed)
			if(manualplace_min_time && world.time >= manualplace_min_time)
				to_chat(src, span_boldnotice("You may now place your blob core."))
				to_chat(src, span_boldannounce("You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)]."))
				manualplace_min_time = 0
			if(autoplace_max_time && world.time >= autoplace_max_time)
				place_blob_core(BLOB_RANDOM_PLACEMENT)
		else
			// If we get here, it means yes: the blob is kill
			qdel(src)
	else if(!antag_team.victory_in_progress && (antag_team.blobs_legit >= antag_team.blobwincount))
		antag_team.victory_in_progress = TRUE
		priority_announce("Biohazard has reached critical mass. Station loss is imminent.", "Biohazard Alert")
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		max_blob_points = INFINITY
		blob_points = INFINITY
		addtimer(CALLBACK(src, PROC_REF(victory)), 450)
	else if(!free_strain_rerolls && ((last_reroll_time + BLOB_POWER_REROLL_FREE_TIME) < world.time))
		to_chat(src, span_boldnotice("You have gained another free strain re-roll."))
		free_strain_rerolls = 1

	if(!antag_team.has_announced && antag_team.announcement_time && \
	(world.time>=antag_team.announcement_time||antag_team.blobs_legit>=antag_team.announcement_size||length(antag_team.all_blobs_by_type[/obj/structure/blob/special/node])>=NODES_TO_ANNOUNCE))
		priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)
		antag_team.has_announced = TRUE

/mob/eye/blob/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(10 SECONDS)
	for(var/mob/living/live_guy as anything in GLOB.mob_living_list)
		var/turf/guy_turf = get_turf(live_guy)
		if(isnull(guy_turf) || !is_station_level(guy_turf.z))
			continue

		if((live_guy in GLOB.overminds) || (live_guy.pass_flags & PASSBLOB))
			continue

		var/area/blob_area = get_area(guy_turf)
		if(!(blob_area.area_flags & BLOBS_ALLOWED))
			continue

		if(!(ROLE_BLOB in live_guy.faction))
			playsound(live_guy, 'sound/effects/splat.ogg', 50, TRUE)
			if(live_guy.stat != DEAD)
				live_guy.investigate_log("has died from blob takeover.", INVESTIGATE_DEATHS)
			live_guy.death()
			antag_team.create_spore(guy_turf, spore_type = /mob/living/basic/blob_minion/spore)
		else
			live_guy.fully_heal()

		for(var/area/check_area in GLOB.areas)
			if(!is_type_in_list(check_area, GLOB.the_station_areas))
				continue
			if(!(check_area.area_flags & BLOBS_ALLOWED))
				continue
			check_area.color = antag_team.blobstrain.color
			check_area.name = "blob"
			check_area.icon = 'icons/mob/nonhuman-player/blob.dmi'
			check_area.icon_state = "blob_shield"
			check_area.layer = BELOW_MOB_LAYER
			check_area.SetInvisibility(INVISIBILITY_NONE)
			check_area.blend_mode = 0

	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(B)
		var/datum/objective/blob_takeover/main_objective = locate() in B.objectives
		main_objective?.completed = TRUE
	to_chat(world, span_blobannounce("[real_name] consumed the station in an unstoppable tide!"))
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = FORCE_END_ROUND

/mob/eye/blob/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_blobannounce("You are the overmind!"))
	if(!placed && autoplace_max_time <= world.time)
		to_chat(src, span_boldannounce("You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)]."))
		to_chat(src, span_boldannounce("You [manualplace_min_time ? "will be able to":"can"] manually place your blob core by pressing the Place Blob Core button in the bottom right corner of the screen."))
	update_health_hud()
	add_points(0)

/mob/eye/blob/examine(mob/user)
	. = ..()
	if(antag_team.blobstrain)
		. += "Its strain is <font color=\"[antag_team.blobstrain.color]\">[antag_team.blobstrain.name]</font>."

/mob/eye/blob/update_health_hud()
	if(!blob_core)
		return FALSE
	var/current_health = round((blob_core.get_integrity() / blob_core.max_integrity) * 100)
	hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>")
	for(var/mob/living/basic/blob_minion/blobbernaut/blobbernaut in antag_team.blob_mobs)
		var/datum/hud/using_hud = blobbernaut.hud_used
		if(!using_hud?.blobpwrdisplay)
			continue
		using_hud.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>")

/mob/eye/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	hud_used.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_points)]</font></div>")

/mob/eye/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && src.client.handle_spam_prevention(message, MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/eye/blob/proc/blob_talk(message)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	src.log_talk(message, LOG_SAY)

	var/message_a = say_quote(message)
	var/rendered = span_big(span_blob("<b>\[Blob Telepathy\] [name](<font color=\"[antag_team.blobstrain.color]\">[antag_team.blobstrain.name]</font>)</b> [message_a]"))
	relay_to_list_and_observers(rendered, GLOB.blob_telepathy_mobs, src)

/mob/eye/blob/blob_act(obj/structure/blob/B)
	return

/mob/eye/blob/get_status_tab_items()
	. = ..()
	if(blob_core)
		. += "Core Health: [blob_core.get_integrity()]"
		. += "Power Stored: [blob_points]/[max_blob_points]"
		. += "Blobs to Win: [antag_team.blobs_legit]/[antag_team.blobwincount]"
	if(free_strain_rerolls)
		. += "You have [free_strain_rerolls] Free Strain Reroll\s Remaining"
	if(!placed)
		if(manualplace_min_time)
			. += "Time Before Manual Placement: [max(round((manualplace_min_time - world.time)*0.1, 0.1), 0)]"
		. += "Time Before Automatic Placement: [max(round((autoplace_max_time - world.time)*0.1, 0.1), 0)]"

/mob/eye/blob/Move(NewLoc, Dir = 0)
	if(placed)
		var/obj/structure/blob/B = locate() in range(OVERMIND_MAX_CAMERA_STRAY, NewLoc)
		if(B)
			forceMove(NewLoc)
		else
			return FALSE
	else
		var/area/check_area = get_area(NewLoc)
		if(isgroundlessturf(NewLoc) || istype(check_area, /area/shuttle)) //if unplaced, can't go on shuttles or groundless tiles
			return FALSE
		forceMove(NewLoc)
		return TRUE

/mob/eye/blob/mind_initialize()
	. = ..()
	var/datum/antagonist/blob/blob = mind.has_antag_datum(/datum/antagonist/blob)
	if(!blob)
		mind.add_antag_datum(/datum/antagonist/blob)

#undef NODES_TO_ANNOUNCE

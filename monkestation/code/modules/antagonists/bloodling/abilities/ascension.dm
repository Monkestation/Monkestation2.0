/datum/action/cooldown/bloodling/ascension
	name = "Ascend"
	desc = "We spread our wings across the station...Mass consumption is required. Costs 500 Biomass and takes 5 minutes for you to ascend."
	button_icon_state = "ascend"
	biomass_cost = 500
	var/static/datum/dimension_theme/chosen_theme
	var/list/responses = list("Yes", "No")

/datum/action/cooldown/bloodling/ascension/PreActivate(atom/target)
	var/mob/living/basic/bloodling/proper/our_mob = owner
	var/datum/antagonist/bloodling/antag = IS_BLOODLING(our_mob)
	if(antag.is_ascended)
		return FALSE
	return ..()

/datum/action/cooldown/bloodling/ascension/Activate(atom/target)
	var/mob/living/basic/bloodling/proper/our_mob = owner
	// Adds 500 biomass back
	our_mob.add_biomass(500)
	var/tgui_response = tgui_alert(our_mob, "Are you prepared to ascend?", "Ascension", responses, 0)
	if(tgui_response == "No")
		return
	var/turf/our_turf = get_turf(our_mob)
	to_chat(our_mob, span_noticealien("You grow a chrysalis to begin the change..."))
	priority_announce("ALERT: LEVEL 4 BIOHAZARD MORPHING IN [get_area(our_turf)]. STOP IT AT ALL COSTS.", "Biohazard")
	our_mob.evolution(6)
	// Waits 5 minutes before calling the ascension
	addtimer(CALLBACK(src, PROC_REF(ascend), our_mob), 5 MINUTES)
	return TRUE

/datum/action/cooldown/bloodling/ascension/proc/ascend(mob/living/basic/bloodling)
	var/mob/living/basic/bloodling/proper/our_mob = owner
	// Calls the shuttle
	SSshuttle.requestEvac(src, "ALERT: LEVEL 4 BIOHAZARD DETECTED. ORGANISM CONTAINMENT HAS FAILED. EVACUATE REMAINING PERSONEL.")
	our_mob.add_biomass(our_mob.biomass_max-our_mob.biomass)
	our_mob.evolution(5)
	var/datum/antagonist/bloodling/antag = IS_BLOODLING(our_mob)
	antag.is_ascended = TRUE

	if(isnull(chosen_theme))
		chosen_theme = new /datum/dimension_theme/bloodling()
	var/turf/start_turf = get_turf(bloodling)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (!chosen_theme.can_convert(transform_turf))
			continue
		var/dist = get_dist(start_turf, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	if (chosen_theme.can_convert(start_turf))
		chosen_theme.apply_theme(start_turf)

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)

/datum/action/cooldown/bloodling/ascension/proc/transform_area(list/turfs)
	for (var/turf/transform_turf as anything in turfs)
		if (!chosen_theme.can_convert(transform_turf))
			continue
		chosen_theme.apply_theme(transform_turf)
		CHECK_TICK


/turf/open/misc/bloodling
	name = "nerve threads"
	icon = 'monkestation/code/modules/antagonists/bloodling/sprites/flesh_tile.dmi'
	icon_state = "flesh_tile-0"
	base_icon_state = "flesh_tile"
	baseturfs = /turf/open/floor/plating
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_BLOODLING
	canSmoothWith = SMOOTH_GROUP_FLOOR_BLOODLING
	layer = HIGH_TURF_LAYER
	underfloor_accessibility = UNDERFLOOR_HIDDEN

/turf/open/misc/bloodling/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.station_turfs += src

	var/matrix/translation = new
	translation.Translate(-9, -9)
	transform = translation
	QUEUE_SMOOTH(src)


/turf/open/misc/bloodling/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if (!.)
		return

	if(!smoothing_flags)
		return

	var/matrix/translation = new
	translation.Translate(-9, -9)
	transform = translation

	underlay_appearance.transform = transform

/datum/dimension_theme/bloodling
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meat"
	sound = 'sound/items/eatfood.ogg'
	replace_floors = list(/turf/open/misc/bloodling = 1)
	replace_walls = /turf/closed/wall/material/meat
	window_colour = "#5c0c0c"
	replace_objs = list(\
		/obj/machinery/atmospherics/components/unary/vent_scrubber = list(/obj/structure/meateor_fluff/eyeball = 1), \
		/obj/machinery/atmospherics/components/unary/vent_pump = list(/obj/structure/meateor_fluff/eyeball = 1),)


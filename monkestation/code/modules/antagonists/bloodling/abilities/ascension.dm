/datum/action/cooldown/bloodling/ascension
	name = "Ascend"
	desc = "We spread our wings across the station...Mass consumption is required. Costs 500 Biomass and takes 5 minutes for you to ascend. Your presence will be alerted to the crew. Fortify the hive."
	button_icon_state = "ascend"
	biomass_cost = 500
	biomass_cap = TRUE

	var/list/responses = list("Yes", "No")

/datum/action/cooldown/bloodling/ascension/PreActivate(atom/target)
	var/mob/living/basic/bloodling/proper/our_mob = owner
	var/datum/antagonist/bloodling/antag = IS_BLOODLING(our_mob)
	if(antag.is_ascended)
		qdel(src)
		return FALSE

	return ..()

/datum/action/cooldown/bloodling/ascension/Activate(atom/target)
	var/mob/living/basic/bloodling/proper/our_mob = owner
	var/choice = tgui_input_list(owner, "Are you REALLY sure you wish to start the ascension process? It will take 5 minutes.", "Are you sure you wish to ascend?", responses)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner))
		return FALSE
	if(choice == "No")
		return FALSE

	var/turf/our_turf = get_turf(our_mob)
	to_chat(our_mob, span_noticealien("You grow a chrysalis to begin the change..."))
	priority_announce("ALERT: LEVEL 4 BIOHAZARD MORPHING IN [get_area(our_turf)]. STOP IT AT ALL COSTS.", "Biohazard")
	playsound(our_turf, 'sound/effects/blobattack.ogg', 60)
	our_mob.evolution(6)
	return TRUE

/mob/living/basic/bloodling/proper/ascending
	name = "Fleshy Cocoon"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "heart"
	icon_living = "heart"
	evolution_level = 6
	initial_powers = list(
		/datum/action/cooldown/mob_cooldown/bloodling/absorb,
		/datum/action/cooldown/mob_cooldown/bloodling/infest,
		/datum/action/cooldown/bloodling/dissonant_shriek,
		/datum/action/cooldown/spell/aoe/repulse/bloodling,
		/datum/action/cooldown/mob_cooldown/bloodling/transfer_biomass,
		/datum/action/cooldown/mob_cooldown/bloodling/heal,
		/datum/action/cooldown/bloodling_hivespeak,
	)
	speed = 0
	move_resist = INFINITY
	var/static/datum/dimension_theme/chosen_theme

/mob/living/basic/bloodling/proper/ascending/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, REF(src))
	addtimer(CALLBACK(src, PROC_REF(ascend)), 5 MINUTES)

/mob/living/basic/bloodling/proper/ascending/evolution_mind_change(mob/living/basic/bloodling/proper/new_bloodling)
	new_bloodling.setDir(dir)
	if(numba)
		new_bloodling.numba = numba
		new_bloodling.set_name()
	new_bloodling.name = name
	new_bloodling.real_name = real_name
	if(mind)
		mind.name = new_bloodling.real_name
		mind.transfer_to(new_bloodling)
	// Runs = instead of add_biomass because the tier 1 bloodling has 50 biomass to start with
	new_bloodling.biomass = biomass

/mob/living/basic/bloodling/proper/ascending/proc/ascend()
	// Calls the shuttle
	SSshuttle.requestEvac(src, "ALERT: LEVEL 4 BIOHAZARD DETECTED. ORGANISM CONTAINMENT HAS FAILED. EVACUATE REMAINING PERSONEL.")
	// Makes it unable to be recalled
	SSshuttle.emergency_no_recall = TRUE

	src.add_biomass(src.biomass_max-src.biomass)
	var/datum/antagonist/bloodling/antag = IS_BLOODLING(src)
	antag.is_ascended = TRUE
	src.evolution(5)

	if(isnull(chosen_theme))
		chosen_theme = new /datum/dimension_theme/bloodling()
	var/turf/start_turf = get_turf(src)
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

/mob/living/basic/bloodling/proper/ascending/proc/transform_area(list/turfs)
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
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-16, -16), matrix())
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


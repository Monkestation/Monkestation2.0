/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'monkestation/code/modules/factory_type_beat/icons/terrain.dmi'
	icon_state = "ore_vent"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// Has this vent been scanned by a mining scanner? Cannot be scanned again. Adds ores to the vent's description.
	var/discovered = FALSE
	/// What icon_state do we use when the ore vent has been tapped?
	var/icon_state_tapped = "ore_vent_active"

	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Reference to this ore vent's NODE drone, to track wave success.
	var/mob/living/basic/node_drone/node = null //this path is a placeholder.

	/// What string do we use to warn the player about the excavation event?
	var/excavation_warning = "Are you ready to excavate this ore vent?"
	///Are we currently spawning mobs?
	var/spawning_mobs = FALSE
		/// A list of mobs that can be spawned by this vent during a wave defense event.
	var/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion/spawner_made,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/bileworm,
	)
	///What items can be used to scan a vent?
	var/static/list/scanning_equipment = list(
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/mining_scanner,
	)

	/// We use a cooldown to prevent the wave defense from being started multiple times.
	COOLDOWN_DECLARE(wave_cooldown)

/obj/structure/ore_vent/Initialize(mapload)
	return ..()

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	if(!is_type_in_list(attacking_item, scanning_equipment))
		return TRUE
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return TRUE
	scan_and_confirm(user)
	return TRUE

/**
 * Starts the wave defense event, which will spawn a number of lavaland mobs based on the size of the ore vent.
 * Called after the vent has been tapped by a scanning device.
 * Will summon a number of waves of mobs, ending in the vent being tapped after the final wave.
 */
/obj/structure/ore_vent/proc/start_wave_defense()
/*
	AddComponent(\
		/datum/component/spawner, \
		spawn_types = defending_mobs, \
		spawn_time = (10 SECONDS + (5 SECONDS * (boulder_size/5))), \
		max_spawned = 10, \
		max_spawn_per_attempt = (1 + (boulder_size/5)), \
		spawn_text = "emerges to assault", \
		spawn_distance = 4, \
		spawn_distance_exclude = 3, \
	)
*/
	var/wave_timer = 60 SECONDS
	if(boulder_size == BOULDER_SIZE_MEDIUM)
		wave_timer = 90 SECONDS
	else if(boulder_size == BOULDER_SIZE_LARGE)
		wave_timer = 150 SECONDS
	COOLDOWN_START(src, wave_cooldown, wave_timer)
	addtimer(CALLBACK(src, PROC_REF(handle_wave_conclusion)), wave_timer)
	spawning_mobs = TRUE
	icon_state = icon_state_tapped
	update_appearance(UPDATE_ICON_STATE)

/**
 * Called when the wave defense event ends, after a variable amount of time in start_wave_defense.
 *
 * If the node drone is still alive, the ore vent is tapped and the ore vent will begin generating boulders.
 * If the node drone is dead, the ore vent is not tapped and the wave defense can be reattempted.
 *
 * Also gives xp and mining points to all nearby miners in equal measure.
 */
/obj/structure/ore_vent/proc/handle_wave_conclusion()

/**
 * Called when the ore vent is tapped by a scanning device.
 * Gives a readout of the ores available in the vent that gets added to the description,
 * then asks the user if they want to start wave defense if it's already been discovered.
 * @params user The user who tapped the vent.
 * @params scan_only If TRUE, the vent will only scan, and not prompt to start wave defense. Used by the mech mineral scanner.
 */
/obj/structure/ore_vent/proc/scan_and_confirm(mob/living/user, scan_only = FALSE)
	if(tapped)
		balloon_alert_to_viewers("vent already tapped!")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		balloon_alert_to_viewers("protect the node drone!")
		return
	if(!discovered)
		if(DOING_INTERACTION_WITH_TARGET(user, src))
			balloon_alert(user, "already scanning!")
			return
		balloon_alert(user, "scanning...")
		playsound(src, 'sound/items/timer.ogg', 30, TRUE)
		if(!do_after(user, 4 SECONDS, target = src) || discovered) // Prevent multiple scan rewards
			return
		discovered = TRUE
		balloon_alert(user, "vent scanned!")
		//generate_description(user)
		var/obj/item/card/id/user_id_card = user.get_idcard(TRUE)
		if(isnull(user_id_card))
			return
		user_id_card.registered_account.mining_points += (MINER_POINT_MULTIPLIER)
		user_id_card.registered_account.bank_card_talk("You've been awarded [MINER_POINT_MULTIPLIER] mining points for discovery of an ore vent.")
		return

	if(scan_only) //Placed here to allow rewards
		return
	if(tgui_alert(user, excavation_warning, "Begin defending ore vent?", list("Yes", "No")) != "Yes")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		return
	//This is where we start spitting out mobs.
	Shake(duration = 3 SECONDS)
	node = new /mob/living/basic/node_drone(loc)
	node.arrive(src)
	RegisterSignal(node, COMSIG_QDELETING, PROC_REF(handle_wave_conclusion))
	particles = new /particles/smoke/ash()

	for(var/i in 1 to 5) // Clears the surroundings of the ore vent before starting wave defense.
		for(var/turf/closed/mineral/rock in oview(i))
			if(istype(rock, /turf/open/misc/asteroid) && prob(35)) // so it's too common
				new /obj/effect/decal/cleanable/rubble(rock)
			if(prob(100 - (i * 15)))
				rock.gets_drilled(user, FALSE)
				if(prob(50))
					new /obj/effect/decal/cleanable/rubble(rock)
		sleep(0.6 SECONDS)

	start_wave_defense()

/**
 * Adds floating temp_visual overlays to the vent, showcasing what minerals are contained within it.
 * If undiscovered, adds a single overlay with the icon_state "unknown".
 */
/obj/structure/ore_vent/proc/add_mineral_overlays()
	var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
	new_mat.icon_state = "unknown"
	return
/*
	if(mineral_breakdown.len && !discovered)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = "unknown"
		return
	for(var/datum/material/selected_mat as anything in mineral_breakdown)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = selected_mat.name
*/
/obj/structure/ore_vent/random

/obj/structure/ore_vent/random/icebox //The one that shows up on the top level of icebox

/obj/structure/ore_vent/random/icebox/lower

/obj/structure/ore_vent/boss

/obj/structure/ore_vent/boss/icebox

#define FLY_IN_STATE 1
#define FLY_OUT_STATE 2
#define NEUTRAL_STATE 3

/**
 * Mining drones that are spawned when starting a ore vent's wave defense minigame.
 * They will latch onto the vent to defend it from lavaland mobs, and will flee if attacked by lavaland mobs.
 * If the drone survives, they will fly away to safety as the vent spawns ores.
 * If the drone dies, the wave defense will fail.
 */
/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining.dmi'
	icon_state = "mining_node_active"
	icon_living = "mining_node_active"
	icon_dead = "mining_node_active"
	maxHealth = 300 // We adjust the max health based on the vent size in the arrive() proc.
	health = 300
	density = TRUE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ROBOTIC
	faction = list(FACTION_STATION, FACTION_NEUTRAL)
	light_outer_range = 4
	basic_mob_flags = DEL_ON_DEATH
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	weather_immunities = list(TRAIT_ASHSTORM_IMMUNE)
	bodytemp_cold_damage_limit = -1

	speak_emote = list("chirps")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "clangs"
	response_harm_simple = "clang against"

	ai_controller = /datum/ai_controller/basic_controller/node_drone

	/// What status do we currently track for icon purposes?
	var/flying_state = NEUTRAL_STATE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null
	/// Set when the drone is begining to leave lavaland after the vent is secured.
	var/escaping = FALSE
	/// Timer to force the drone to return if it leaves the vent.
	var/unbuckled_timer = null

/mob/living/basic/node_drone/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate/enemies)
	ADD_TRAIT(src, TRAIT_TENTACLE_IMMUNE, INNATE_TRAIT)

/mob/living/basic/node_drone/death(gibbed)
	. = ..()
	explosion(origin = src, light_impact_range = 1, smoke = 1)

/mob/living/basic/node_drone/Destroy()
	if(!isnull(attached_vent))
		UnregisterSignal(attached_vent, COMSIG_MOVABLE_BUCKLE)
		UnregisterSignal(attached_vent, COMSIG_MOVABLE_UNBUCKLE)
		attached_vent?.node = null //clean our reference to the vent both ways.
		attached_vent = null
	return ..()

/mob/living/basic/node_drone/examine(mob/user)
	. = ..()
	var/sameside = user.faction_check_atom(src, exact_match = FALSE)
	if(sameside)
		. += span_notice("This drone is currently attached to a mineral vent. You should protect it from harm to secure the mineral vent.")
	else
		. += span_warning("This vile Nanotrasen trash is trying to destroy the environment. Attack it to free the mineral vent from its grasp.")

/mob/living/basic/node_drone/update_icon_state()
	. = ..()

	icon_state = "mining_node_active"

	if(flying_state == FLY_IN_STATE || flying_state == FLY_OUT_STATE)
		icon_state = "mining_node_flying"

/mob/living/basic/node_drone/Life()
	. = ..()

	if(!isnull(attached_vent))
		update_appearance(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/mob/living/basic/node_drone/update_overlays()
	. = ..()

	if(attached_vent)
		var/time_remaining = attached_vent?.wave_time_remaining()
		var/wave_timers = attached_vent?.wave_timer
		if(isnull(time_remaining) || isnull(wave_timers) || wave_timers == 0)
			return
		var/remaining_fraction = (time_remaining != 0) ? (time_remaining / wave_timers) : 0
		if(remaining_fraction <= 0.3)
			. += "node_progress_4"
			return
		if(remaining_fraction <= 0.55)
			. += "node_progress_3"
			return
		if(remaining_fraction <= 0.80)
			. += "node_progress_2"
			return
		. += "node_progress_1"
		return

/mob/living/basic/node_drone/proc/arrive(obj/structure/ore_vent/parent_vent)
	src.ai_controller?.set_ai_status(AI_STATUS_OFF) // Turns off Ai if it has one.
	attached_vent = parent_vent
	maxHealth = 300 + ((attached_vent.boulder_size/BOULDER_SIZE_SMALL) * 100)
	health = maxHealth
	flying_state = FLY_IN_STATE
	update_appearance(UPDATE_ICON_STATE)
	pixel_z = 400
	animate(src, pixel_z = 0, time = 2 SECONDS, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	RegisterSignal(attached_vent, COMSIG_MOVABLE_BUCKLE, PROC_REF(did_buckle))
	RegisterSignal(attached_vent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(did_buckle))

/**
 * Called when wave defense is completed. Visually flicks the escape sprite and then deletes the mob.
 */
/mob/living/basic/node_drone/proc/escape(failed)
	var/funny_ending = FALSE
	flying_state = FLY_OUT_STATE
	update_appearance(UPDATE_ICON_STATE)
	if(!failed)
		if(prob(1) || check_holidays(APRIL_FOOLS))
			say("I have to go now, my planet needs me.")
			funny_ending = TRUE
		visible_message(span_notice("The drone flies away to safety as the vent is secured."))
	else
		visible_message(span_notice("The drone flies away to safety in fear. Next time DEFEND THE DRONE!"))
	attached_vent?.pause_resume_wave(FALSE)
	animate(src, pixel_z = 400, time = 2 SECONDS, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(2 SECONDS)
	if(funny_ending)
		playsound(src, 'sound/effects/explosion3.ogg', 50, FALSE) //node drone died on the way back to his home planet.
		visible_message(span_notice("...or maybe not."))
	qdel(src)

/mob/living/basic/node_drone/proc/pre_escape(success)
	var/time_out = FALSE
	if(attached_vent)
		if(!isnull(attached_vent?.wave_time_remaining()))
			time_out = TRUE
		attached_vent = null
		update_appearance(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	src.ai_controller?.set_ai_status(AI_STATUS_OFF) // Turns off Ai if it has one.
	buckled?.unbuckle_mob(src) // Unbuckle us from whatever it is. Prevents runtimes.
	pull_force = MOVE_FORCE_VERY_STRONG // You can no longer pull it. Time to go.
	if(!escaping)
		escaping = TRUE
		flick("mining_node_escape", src)
		addtimer(CALLBACK(src, PROC_REF(escape), time_out), 1.9 SECONDS)
		return

/mob/living/basic/node_drone/proc/did_buckle(source, mob, was_buckled)
	SIGNAL_HANDLER
	if(mob == src)
		attached_vent?.pause_resume_wave(was_buckled)
		update_appearance(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		if(was_buckled)
			deltimer(unbuckled_timer)
			unbuckled_timer = null
		else if(isnull(unbuckled_timer))
			unbuckled_timer = addtimer(CALLBACK(src, PROC_REF(pre_escape)), 12 SECONDS, TIMER_STOPPABLE)

/// The node drone AI controller
//	Generally, this is a very simple AI that will try to find a vent and latch onto it, unless attacked by a lavaland mob, who it will try to flee from.
/datum/ai_controller/basic_controller/node_drone
	blackboard = list(
		BB_CURRENT_HUNTING_TARGET = null, // Hunts for vents.
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic, // Use this to find vents to run away from assailants.
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null // Should be mining or trying to do something. No idling.
	planning_subtrees = list(
		// Priority is see if lavaland mobs are attacking us to flee from them.
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		// Fly you fool
		/datum/ai_planning_subtree/flee_target/node_drone,
		// Otherwise, look for and execute hunts for vents to latch onto.
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_vent,
	)

// Node subtree to hunt down ore vents. Should focus on the one it is parented to first. (Until extended behavior is added later.)
/datum/ai_planning_subtree/find_and_hunt_target/look_for_vent
	hunting_behavior = /datum/ai_behavior/hunt_target/latch_onto/node_drone
	hunt_targets = list(/obj/structure/ore_vent) // What it will look for if it doesn't have a target.
	hunt_range = 7 // Hunt vents to the end of the earth.

// Finish override to make the drone return to hunting behavior sooner.
/datum/ai_behavior/run_away_from_target/drone/finish_action(datum/ai_controller/controller, succeeded, target_key, hiding_location_key)
	if(succeeded)
		var/list/shitlist = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		var/atom/existing_target = controller.blackboard[target_key]
		if(length(shitlist) && (existing_target in shitlist)) // Drone is dumb and forgets all assualts when it gets away.
			controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
	return ..() // Must be done after as target_key gets cleared by parent.

// node drone behavior for buckling down on a vent.
/datum/ai_behavior/hunt_target/latch_onto/node_drone
	hunt_cooldown = 5 SECONDS

// Evasion behavior.
/datum/ai_planning_subtree/flee_target/node_drone
	flee_behaviour = /datum/ai_behavior/run_away_from_target/drone

/datum/ai_behavior/run_away_from_target/drone
	action_cooldown = 1 SECONDS
	run_distance = 3

/datum/ai_behavior/run_away_from_target/drone/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()

	var/mob/living/coward = controller.pawn
	if(istype(coward) && coward.buckled)
		coward.buckled.unbuckle_mob(coward)

#undef FLY_IN_STATE
#undef FLY_OUT_STATE
#undef NEUTRAL_STATE

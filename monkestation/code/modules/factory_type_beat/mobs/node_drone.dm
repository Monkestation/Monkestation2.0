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
	minimum_survivable_temperature = 0

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
		attached_vent.update_progress_bar()

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
		playsound(src, 'sound/effects/explosion/explosion3.ogg', 50, FALSE) //node drone died on the way back to his home planet.
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
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/node_drone/node_drone.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic, // Use this to find vents to run away from assailants.
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

/// Finds a vent to latch onto. Should focus on the one it is parented to first.
/datum/bt_node/ai_behavior/node_drone_find_vent
	time_between_perform = 2 SECONDS
	/// Blackboard key the vent we found goes in
	var/target_key = BB_CURRENT_HUNTING_TARGET
	/// How far we look for vents
	var/hunt_range = 7

/datum/bt_node/ai_behavior/node_drone_find_vent/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/mob/living/basic/node_drone/drone = controller.pawn
	var/obj/structure/ore_vent/parent_vent = drone.attached_vent
	if(istype(parent_vent) && !QDELETED(parent_vent))
		controller.set_blackboard_key(target_key, parent_vent)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	for(var/obj/structure/ore_vent/vent in range(hunt_range, drone))
		controller.set_blackboard_key(target_key, vent)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Lets go of the vent so we can run
/datum/bt_node/ai_behavior/node_drone_unlatch

/datum/bt_node/ai_behavior/node_drone_unlatch/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/coward = controller.pawn
	coward.buckled?.unbuckle_mob(coward)
	return AI_BEHAVIOR_SUCCEEDED

/// Drone is dumb and forgets all assaults once it gets away
/datum/bt_node/ai_behavior/node_drone_forget_attackers
	/// How far we need to get before we feel safe
	var/safe_distance = 3

/datum/bt_node/ai_behavior/node_drone_forget_attackers/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/attacker = controller.blackboard[BB_CURRENT_TARGET]
	if(isnull(attacker) || get_dist(controller.pawn, attacker) <= safe_distance)
		return AI_BEHAVIOR_FAILED
	controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
	controller.clear_blackboard_key(BB_CURRENT_TARGET)
	return AI_BEHAVIOR_SUCCEEDED

#undef FLY_IN_STATE
#undef FLY_OUT_STATE
#undef NEUTRAL_STATE

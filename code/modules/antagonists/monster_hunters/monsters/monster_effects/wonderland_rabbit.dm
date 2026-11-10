// not a subtype of /mob/living/basic/rabbit as those have several elements we don't want to inherit
/mob/living/basic/wonderland_rabbit
	name = /mob/living/basic/rabbit::name
	desc = /mob/living/basic/rabbit::desc
	icon = 'icons/mob/wonderland_rabbit.dmi'
	icon_state = "white_rabbit"
	icon_living = "white_rabbit"
	dir = EAST
	density = FALSE
	pass_flags = PASSTABLE | PASSFLAPS | PASSDOORS
	health = 75
	maxHealth = 75
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	basic_mob_flags = DEL_ON_DEATH
	gold_core_spawnable = NONE
	faction = list(FACTION_RABBITS)
	sentience_type = SENTIENCE_BOSS
	ai_controller = /datum/ai_controller/basic_controller/wonderland_rabbit
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	/// The hunter whose rifts let us in.
	var/datum/antagonist/monsterhunter/hunter_antag
	/// Whether we're frozen in place, eyes glowing, watching someone.
	var/staring = FALSE
	COOLDOWN_DECLARE(roam_cooldown)
	/// Not normal rabbits by any means, they're fantastical entities that don't follow the same laws of reality.
	var/static/list/innate_traits = list(
		TRAIT_ANTIMAGIC,
		TRAIT_NO_MINDSWAP,
		TRAIT_SHOCKIMMUNE,
	)

/mob/living/basic/wonderland_rabbit/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	add_traits(innate_traits, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	COOLDOWN_START(src, roam_cooldown, rand(1 MINUTES, 4 MINUTES))
	if(istype(hunter) && !QDELING(hunter))
		hunter_antag = hunter
		hunter.wonderland_rabbits += src

/mob/living/basic/wonderland_rabbit/Destroy()
	hunter_antag?.wonderland_rabbits -= src
	hunter_antag = null
	return ..()

/mob/living/basic/wonderland_rabbit/death(gibbed)
	var/obj/effect/wonderland_rabbit_exit/exit = new(loc)
	exit.setDir(dir)
	return ..()

/mob/living/basic/wonderland_rabbit/update_overlays()
	. = ..()
	if(staring)
		. += emissive_appearance(icon, "[icon_state]_e", src)

/mob/living/basic/wonderland_rabbit/proc/set_staring(atom/target)
	setDir(get_dir(src, target))
	if(staring)
		return
	staring = TRUE
	ADD_TRAIT(src, TRAIT_AI_PAUSED, REF(src))
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/wonderland_rabbit/proc/stop_staring()
	if(!staring)
		return
	staring = FALSE
	REMOVE_TRAIT(src, TRAIT_AI_PAUSED, REF(src))
	update_appearance(UPDATE_OVERLAYS)

/datum/ai_controller/basic_controller/wonderland_rabbit
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/wonderland_rabbit_roam,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
	)

/// Now and then, picks somewhere far off for travel_to_point to walk us to
/datum/ai_planning_subtree/wonderland_rabbit_roam

/datum/ai_planning_subtree/wonderland_rabbit_roam/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/wonderland_rabbit/rabbit = controller.pawn
	if(!COOLDOWN_FINISHED(rabbit, roam_cooldown) || controller.blackboard_key_exists(BB_TRAVEL_DESTINATION))
		return
	COOLDOWN_START(rabbit, roam_cooldown, rand(4 MINUTES, 8 MINUTES))
	var/turf/here = get_turf(rabbit)
	for(var/i in 1 to 10)
		var/turf/candidate = locate(here.x + rand(-25, 25), here.y + rand(-25, 25), here.z)
		if(!isopenturf(candidate) || get_dist(here, candidate) < 10 || candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue
		controller.set_blackboard_key(BB_TRAVEL_DESTINATION, candidate)
		return

/obj/effect/wonderland_rabbit_enter
	name = "rabbit?"
	icon = 'icons/mob/wonderland_rabbit.dmi'
	icon_state = "rabbit_enter"
	/// Passed on to the rabbit that hops out.
	var/datum/antagonist/monsterhunter/hunter_antag

/obj/effect/wonderland_rabbit_enter/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	hunter_antag = hunter
	update_appearance(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(finish_animation)), 4 SECONDS)

/obj/effect/wonderland_rabbit_enter/Destroy()
	hunter_antag = null
	return ..()

/obj/effect/wonderland_rabbit_enter/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)

/obj/effect/wonderland_rabbit_enter/proc/finish_animation()
	new /mob/living/basic/wonderland_rabbit(loc, hunter_antag)
	qdel(src)

/obj/effect/wonderland_rabbit_exit
	name = "rabbit"
	icon = 'icons/mob/wonderland_rabbit.dmi'
	icon_state = "rabbit_hole"

/obj/effect/wonderland_rabbit_exit/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	QDEL_IN(src, 8 SECONDS)

/obj/effect/wonderland_rabbit_exit/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)

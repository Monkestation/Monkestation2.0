/datum/ai_controller/chicken
	behavior_tree_json = "monkestation/code/modules/ranching/chickens/ai/ranch_chicken.bt.json"
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/chicken,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Cluck!", "BWAAAAARK BWAK BWAK BWAK!", "Bwaak bwak."),
			BB_EMOTE_HEAR = list("clucks.", "croons."),
			BB_EMOTE_SEE = list("pecks at the ground.", "flaps their wings viciously."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/chicken/clucks.ogg', 'sound/mobs/non-humanoids/chicken/bagawk.ogg'),
			BB_SPEAK_CHANCE = 15,
		),
	)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

/datum/ai_controller/chicken/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/chicken/living_pawn = new_pawn
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown

	AddComponent(/datum/component/connect_loc_behalf, new_pawn, loc_connections)
	return ..() //Run parent at end

/datum/ai_controller/chicken/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_MOB_MOVESPEED_UPDATED))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	return ..()//Run parent at end

//HOSTILE
/datum/ai_controller/chicken/hostile
	behavior_tree_json = "monkestation/code/modules/ranching/chickens/ai/ranch_chicken_hostile.bt.json"

//RETALIATE
/datum/ai_controller/chicken/retaliate
	behavior_tree_json = "monkestation/code/modules/ranching/chickens/ai/ranch_chicken_retaliate.bt.json"

/// Won't go after friends of ours
/datum/targeting_strategy/basic/chicken

/datum/targeting_strategy/basic/chicken/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	if(SEND_SIGNAL(living_mob, COMSIG_FRIENDSHIP_CHECK_LEVEL, target, FRIENDSHIP_FRIEND))
		return FALSE
	return ..()

// Stops sentient chickens from being knocked over like weak dunces.
/datum/ai_controller/chicken/on_sentience_gained()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))

/datum/ai_controller/chicken/on_sentience_lost()
	. = ..()
	AddComponent(/datum/component/connect_loc_behalf, pawn, loc_connections)

/datum/ai_controller/chicken/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown

/datum/ai_controller/chicken/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && isliving(arrived))
		var/mob/living/in_the_way_mob = arrived
		in_the_way_mob.knockOver(living_pawn)
		return


/datum/ai_controller/basic_controller/chick
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/chicken/chick.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/chicken),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/chick),
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Cherp.", "Cherp?", "Chirrup.", "Cheep!"),
			BB_EMOTE_HEAR = list("cheeps."),
			BB_EMOTE_SEE = list("pecks at the ground.", "flaps their tiny wings."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/chicken/chick_peep.ogg'),
			BB_SPEAK_CHANCE = 4,
		),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

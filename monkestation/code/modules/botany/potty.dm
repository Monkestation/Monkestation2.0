/mob/living/basic/pet/potty
	name = "\proper craig the potted plant"
	desc = "A potted plant."

	icon = 'monkestation/code/modules/botany/icons/potty.dmi'
	icon_state = "potty"
	icon_living = "potty_living"
	icon_dead = "potty_dead"

	dexterous = TRUE

	ai_controller = /datum/ai_controller/basic_controller/craig

	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/craig_harvest,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/point_targeting/attack/dog,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)

/mob/living/basic/pet/potty/Initialize(mapload)
	..()
	// Allows Craig to be given different watering cans.
	// You can change the transfer amount so Craig uses more water.
	AddComponent(/datum/component/item_receiver, \
		list(/obj/item/reagent_containers/cup/watering_can), "happily takes")
	AddComponent(/datum/component/plant_tray_overlay, icon, \
			null, null, null, null, null, null, 3, 8)
	AddComponent(/datum/component/plant_growing)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/emotion_buffer)
	AddComponent(/datum/component/friendship_container, list(
		FRIENDSHIP_HATED = -100,
		FRIENDSHIP_DISLIKED = -50,
		FRIENDSHIP_STRANGER = 0,
		FRIENDSHIP_NEUTRAL = 1,
		FRIENDSHIP_ACQUAINTANCES = 3,
		FRIENDSHIP_FRIEND = 5,
		FRIENDSHIP_BESTFRIEND = 10
		), \
		FRIENDSHIP_FRIEND)
	AddComponent(/datum/component/basic_inhands)
	AddElement(/datum/element/waddling)

	SEND_SIGNAL(src, COMSIG_TOGGLE_BIOBOOST)

	return INITIALIZE_HINT_LATELOAD

/mob/living/basic/pet/potty/Destroy()
	drop_all_held_items()
	return ..()

/mob/living/basic/pet/potty/death(gibbed)
	drop_all_held_items()
	return ..()


/mob/living/basic/pet/potty/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	var/obj/item/reagent_containers/cup/watering_can/held_can = \
			is_holding_item_of_type(/obj/item/reagent_containers/cup/watering_can)

	// waters the obj that can grow plants
	if(attack_target.GetComponent(/datum/component/plant_growing) && held_can)
		treat_hydro_tray(attack_target)
		INVOKE_ASYNC(held_can, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, attack_target)
		return

	// fills the watering can
	if(istype(attack_target, /obj/structure/sink) \
			|| istype(attack_target, /obj/structure/reagent_dispensers))
		if(held_can)
			INVOKE_ASYNC(held_can, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, attack_target)
			return
	. = ..()
	return

///Craig can remove weeds or remove dead plants
/mob/living/basic/pet/potty/proc/treat_hydro_tray(atom/movable/hydro)
	var/datum/component/plant_growing/growing = \
			hydro.GetComponent(/datum/component/plant_growing)
	if(!growing)
		return

	for(var/_item, seed_item in growing.managed_seeds)
		var/obj/item/seeds/seed = seed_item
		if(!seed)
			continue
		var/datum/component/growth_information/info = \
				seed.GetComponent(/datum/component/growth_information)

		if(info.plant_state == HYDROTRAY_PLANT_DEAD)
			balloon_alert_to_viewers("dead plant removed")
			SEND_SIGNAL(hydro, COMSIG_REMOVE_PLANT, seed_item)
			return

		if(growing.weed_level > 0)
			balloon_alert_to_viewers("weeds uprooted")
			SEND_SIGNAL(hydro, COMSIG_PLANT_ADJUST_WEED, -10)
			return

// craig's living icons are movement states, so we gotta ensure icon2html handles that properly
/mob/living/basic/pet/potty/get_examine_string(mob/user, thats = FALSE)
	var/is_icon_moving = (icon_state == initial(icon_state) || icon_state == initial(icon_living))
	return "[icon2html(src, user, moving = is_icon_moving)] [thats ? "That's " : ""][get_examine_name(user)]"

/datum/pet_command/craig_harvest
	command_name = "Shake"
	command_desc = "Command your pet to stay idle in this location."
	radial_icon = 'icons/obj/objects.dmi'
	radial_icon_state = "dogbed"
	speech_commands = list("shake", "harvest")
	command_feedback = "shakes"

/datum/pet_command/craig_harvest/execute_action(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	pawn.Shake(2, 2, 3 SECONDS)
	SEND_SIGNAL(pawn, COMSIG_TRY_HARVEST_SEEDS, pawn)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/ai_controller/basic_controller/craig
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/watering_can,
		/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan,
		/datum/ai_planning_subtree/find_and_hunt_target/treat_hydroplants,
	)

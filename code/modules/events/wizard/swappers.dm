/datum/round_event_control/wizard/swappers
	name = "The Swappers"
	weight = 1
	typepath = /datum/round_event/wizard/swappers
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Spawn a group of ghost players with AOE mindswap."
	admin_setup = list(/datum/event_admin_setup/input_number/swappers)

/datum/round_event/wizard/swappers
	///how many swappers to spawn
	var/amount_to_spawn = 2

/datum/round_event/wizard/swappers/start()
	var/list/candidates = SSpolling.poll_ghost_candidates("Would you like to be a [span_notice("magical mind swapper")]?",
														check_jobban = ROLE_WIZARD,
														alert_pic = /obj/item/clothing/head/wizard,
														role_name_text = "swapper")

	var/spawned = 0
	while(length(candidates) && spawned < amount_to_spawn)
		spawned++
		var/mob/picked = pick_n_take(candidates)
		var/turf/spawn_at = get_safe_random_station_turf()
		var/mob/living/carbon/human/created = new /mob/living/carbon/human(spawn_at)
		do_smoke(4, holder = created, location = spawn_at)
		created.PossessByPlayer(picked.key)
		created.mind.add_antag_datum(/datum/antagonist/wizard/swapper)
		created.mind.special_role = ROLE_WIZARD_APPRENTICE
		created.log_message("is a swapper!", LOG_ATTACK, color = "red")
		SEND_SOUND(created, sound('sound/effects/magic.ogg'))
		announce_to_ghosts(created)

/datum/event_admin_setup/input_number/swappers
	input_text = "How many swappers do you want to spawn?"
	default_value = 2
	max_value = 10

/datum/event_admin_setup/input_number/swappers/apply_to_event(datum/round_event/wizard/swappers/event)
	event.amount_to_spawn = chosen_value

/datum/action/cooldown/spell/aoe/mind_swap/swapper
	name = "Mind Swap(swapper)"
	///Does our owner currently have the maptext we give
	var/has_text = FALSE
	///The holder for our maptext
	var/static/atom/movable/maptext_holder/multi_parent/holder

/datum/action/cooldown/spell/aoe/mind_swap/swapper/Grant(mob/grant_to)
	. = ..()
	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(!manager)
		manager = new
		GLOB.maptext_manager = manager
	if(!holder)
		holder = manager.add_keyed_maptext("swapper", "They are here to take your brain.", -32, 32, 112, added_holder = new /atom/movable/maptext_holder/multi_parent)
	manager.add_multi_parent(holder, grant_to)
	has_text = TRUE

/datum/action/cooldown/spell/aoe/mind_swap/swapper/Remove(mob/living/remove_from)
	. = ..()
	if(has_text)
		GLOB.maptext_manager.remove_multi_parent(holder, remove_from)

/datum/action/cooldown/spell/aoe/mind_swap/swapper/cast(atom/cast_on)
	if(has_text)
		GLOB.maptext_manager.remove_multi_parent(holder, owner) //make sure to remove our maptext BEFORE we call parent
		has_text = FALSE
	return ..()

/datum/action/cooldown/spell/aoe/mind_swap/swapper/process()
	. = ..()
	if(!has_text && next_use_time <= world.time)
		GLOB.maptext_manager.add_multi_parent(holder, owner)
		has_text = TRUE

#define REVENANT_SPAWN_THRESHOLD 20

/datum/round_event_control/revenant
	name = "Spawn Revenant" // Did you mean 'griefghost'?
	typepath = /datum/round_event/ghost_role/revenant
	weight = 7
	max_occurrences = 1
	min_players = 5
	//dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns an angry, soul sucking ghost."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/revenant
	var/ignore_mobcheck = FALSE
	role_name = "revenant"

/datum/round_event/ghost_role/revenant/New(my_processing = TRUE, new_ignore_mobcheck = FALSE)
	..()
	ignore_mobcheck = new_ignore_mobcheck

/datum/round_event/ghost_role/revenant/spawn_role()
	if(!ignore_mobcheck)
		var/deadMobs = 0
		for(var/mob/M in GLOB.dead_mob_list)
			deadMobs++
		if(deadMobs < REVENANT_SPAWN_THRESHOLD)
			message_admins("Event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")
			return WAITING_FOR_SOMETHING

	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_REVENANT, role = ROLE_REVENANT, alert_pic = /mob/living/basic/revenant)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/selected = pick_n_take(candidates)

	// monkestation start: refactor to use shared find_possible_revenant_spawns proc
	var/list/spawn_locs = find_possible_revenant_spawns()
	if(!length(spawn_locs)) //If we can't find either, just spawn the revenant at the player's location
		spawn_locs += get_turf(selected)
	if(!length(spawn_locs)) //If we can't find THAT, then just give up and cry
		return MAP_ERROR
	// monkestation end

	var/mob/living/basic/revenant/revvie = new(pick(spawn_locs))
	revvie.PossessByPlayer(selected.key)
	message_admins("[ADMIN_LOOKUPFLW(revvie)] has been made into a revenant by an event.")
	revvie.log_message("was spawned as a revenant by an event.", LOG_GAME)
	spawned_mobs += revvie
	qdel(selected)
	return SUCCESSFUL_SPAWN

#undef REVENANT_SPAWN_THRESHOLD

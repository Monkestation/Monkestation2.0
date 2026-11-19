/datum/round_event_control/wizard/ghost //The spook is real
	name = "G-G-G-Ghosts!"
	weight = 0
	typepath = /datum/round_event/wizard/ghost
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "Ghosts become visible."

/datum/round_event/wizard/ghost/start()
	var/msg = span_warning("You suddenly feel extremely obvious...")
	set_observer_default_invisibility(0, msg)


//--//

/datum/round_event_control/wizard/possession //Oh shit
	name = "Possessing G-G-G-Ghosts!"
	weight = 2
	typepath = /datum/round_event/wizard/possession
	max_occurrences = 5
	earliest_start = 0 MINUTES
	description = "Ghosts become visible and gain the power of possession."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 3

/datum/round_event/wizard/possession/start()
	for(var/mob/dead/observer/G in GLOB.player_list)
		ASSIGN_GAME_VERB(G, /mob/dead/observer, boo)
		ASSIGN_GAME_VERB(G, /mob/dead/observer, possess)
		to_chat(G, "You suddenly feel a welling of new spooky powers...")

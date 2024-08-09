//some gang objectives are still subtypes of other things due to those types handling more logic than this
/datum/traitor_objective/gang
	name = "gang objective"
	description = "this is a gang objective, also something broke if your seeing this"
	progression_minimum = 5 MINUTES //gangs start with no valid objectives to make sure they claim a few areas
	valid_uplinks = UPLINK_GANGS
	global_progression_influence_intensity = 0
	abstract_type = /datum/traitor_objective/gang_secondary_objective

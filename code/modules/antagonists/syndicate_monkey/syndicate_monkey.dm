/datum/antagonist/syndicate_monkey
	name = "\improper Syndicate Monkey"
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	show_in_roundend = TRUE
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE
	show_to_ghosts = TRUE
	/// The antagonist's master, used for objective
	var/mob/living/monky_master

/datum/antagonist/syndicate_monkey/on_gain()
	monky_master = owner.enslaved_to?.resolve()
	forge_objectives(monky_master)
	return ..()

/datum/antagonist/syndicate_monkey/Destroy()
	monky_master = null
	return ..()

/datum/antagonist/syndicate_monkey/greet()
	. = ..()
	owner.announce_objectives()

/datum/objective/syndicate_monkey
	var/mob/living/monky_master

/datum/objective/syndicate_monkey/check_completion()
	if(!monky_master)
		return TRUE
	return monky_master.stat != DEAD

/datum/antagonist/syndicate_monkey/forge_objectives(mob/monky_master)
	if(monky_master)
		var/datum/objective/syndicate_monkey/objective = new
		objective.monky_master = monky_master
		objective.explanation_text = "You are a badass monkey syndicate agent. Protect and obey all of your master [monky_master]'s orders!"
		objective.owner = owner
		objectives += objective
	else
		var/datum/objective/syndicate_monkey/objective = new
		objective.monky_master = monky_master
		objective.explanation_text = "You are a badass monkey syndicate agent. Sabotage the efforts of the station, DEATH TO NANOTRASEN!"
		objective.owner = owner
		objectives += objective

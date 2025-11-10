

/datum/heretic_knowledge/ritual_lore
	name = "The Endless Call"
	desc = "Ritual knowledge"
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list()
	cost = 0
	route = PATH_START
	var/user_path = PATH_START
	var/ritual_progress = 0

/datum/heretic_knowledge/ritual_lore/proc/update_ritual_req(mob/living/user)
	if(user.ritual_progression <= 3)
		required_atoms = side_ritual_items + low_risk_ritual
	if((user.ritual_progression >= 4 ) && (user.ritual_progression <= 6))
		required_atoms = side_ritual_items + med_risk_ritual
	if(user.ritual_progression >= 7)
		required_atoms = side_ritual_items + high_risk_ritual

/datum/heretic_knowledge/ritual_lore/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	LAZYNULL(heretic_datum.current_sac_targets)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		loc.balloon_alert(user, "ritual failed, no targets found!")
		return FALSE

	return TRUE

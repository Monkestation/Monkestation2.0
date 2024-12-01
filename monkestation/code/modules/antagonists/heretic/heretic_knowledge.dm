/datum/heretic_knowledge/ultimate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/static/have_set_lambda = FALSE
	if(. && !have_set_lambda)
		for(var/datum/antagonist/heretic/heretic in GLOB.antagonists)
			var/mob/living/heretic_body = heretic.owner?.current
			if(QDELETED(heretic_body) || heretic_body == user || heretic_body.stat == DEAD)
				continue
			if(heretic.ascended) // technically i could just put !heretic.ascended in the continue check above, but i feel this is easier to read
				have_set_lambda = TRUE
				message_admins("Alert level automatically being raised to Lambda in 5 seconds due to the presence of two or more living ascended heretics")
				addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_LAMBDA), 5 SECONDS, TIMER_UNIQUE)
				return

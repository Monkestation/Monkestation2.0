/// Inflicts crippling brain damage on the target
/datum/smite/feeling_funny
	name = "Feeling Funny (Toggle)"

/datum/smite/feeling_funny/effect(client/user, mob/living/target)
	. = ..()
	if(target.has_status_effect(/datum/status_effect/feeling_funny))
		target.remove_status_effect(/datum/status_effect/feeling_funny)
		to_chat(user,span_admin("[target] now has normal controls!"))
	else
		target.apply_status_effect(/datum/status_effect/feeling_funny,-1,TRUE)
		to_chat(user,span_admin("[target] now has funny controls!"))

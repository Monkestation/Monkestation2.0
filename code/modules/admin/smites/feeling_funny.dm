/// Inflicts crippling brain damage on the target
/datum/smite/feeling_funny
	name = "Feeling Funny"

/datum/smite/feeling_funny/effect(client/user, mob/living/target)
	. = ..()
	target.apply_status_effect(/datum/status_effect/feeling_funny,-1,TRUE)

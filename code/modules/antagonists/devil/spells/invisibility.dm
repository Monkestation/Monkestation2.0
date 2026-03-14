#define ALPHA_INVISIBILE 35

/datum/action/cooldown/spell/devil/invisibility
	name = "Devilish invisibility"
	desc = "Using infernal power you blend into your surroundings."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "invisibility"
	school = SCHOOL_FORBIDDEN
	cooldown_time = 10 SECONDS
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

/datum/action/cooldown/spell/devil/invisibility/Remove(mob/living/remove_from)
	if(remove_from)
		remove_cloaking(remove_from)
	return ..()

/datum/action/cooldown/spell/devil/invisibility/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.alpha == ALPHA_INVISIBILE)
		remove_cloaking(cast_on)
	else
		cast_on.alpha = ALPHA_INVISIBILE
		to_chat(cast_on, span_notice("You activate your camouflage and blend into your surroundings..."))

/datum/action/cooldown/spell/devil/invisibility/proc/remove_cloaking(atom/target)
	target.alpha = initial(target.alpha)
	to_chat(target, span_notice("You disable your camouflage, and become visible once again."))

#undef ALPHA_INVISIBILE

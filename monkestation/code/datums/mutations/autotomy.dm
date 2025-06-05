/datum/mutation/human/self_amputation
	power_coeff = 1

/datum/mutation/human/self_amputation/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/self_amputation/modified_power = .
	modified_power.mood_multiplier = GET_MUTATION_SYNCHRONIZER(src)

	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_LIMBATTACHMENT, GENETIC_MUTATION)

/datum/mutation/human/self_amputation/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_LIMBATTACHMENT, GENETIC_MUTATION)

/datum/action/cooldown/spell/self_amputation
	var/mood_multiplier = 1

/datum/action/cooldown/spell/self_amputation/cast(mob/living/carbon/cast_on)
	. = ..()
	var/datum/mood_event/dismembered/mood = cast_on.mob_mood.mood_events["dismembered"]
	if(mood)
		mood.mood_change *= mood_multiplier
		cast_on.mob_mood.update_mood()

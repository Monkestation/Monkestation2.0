/mob/living/carbon/human/register_init_signals()
	. = ..()

	cascade_trait(TRAIT_HUSK, TRAIT_NOBLOOD)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PALE_GREY_SKIN), PROC_REF(on_pale_grey_skin_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PALE_GREY_SKIN), PROC_REF(on_pale_grey_skin_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOPASSOUT), PROC_REF(on_nopassout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOPASSOUT), PROC_REF(on_nopassout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOHARDCRIT), PROC_REF(on_nohardcrit_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOHARDCRIT), PROC_REF(on_nohardcrit_trait_loss))

	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD), PROC_REF(on_lose_noblood_trait))

/mob/living/carbon/human/proc/on_pale_grey_skin_trait_gain(datum/source)
	SIGNAL_HANDLER
	for(var/obj/item/bodypart/part as anything in bodyparts)
		part.variable_color = "#b8b8b8"
	update_body_parts()

/mob/living/carbon/human/proc/on_pale_grey_skin_trait_loss(datum/source)
	SIGNAL_HANDLER
	for(var/obj/item/bodypart/part as anything in bodyparts)
		part.variable_color = null
	update_body_parts()

/mob/living/carbon/human/proc/on_nopassout_trait_gain(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_NOPASSOUT, OXYLOSS_TRAIT)

/mob/living/carbon/human/proc/on_nopassout_trait_loss(datum/source)
	SIGNAL_HANDLER
	check_passout(getOxyLoss())

/mob/living/carbon/human/proc/on_nohardcrit_trait_gain(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)

/mob/living/carbon/human/proc/on_nohardcrit_trait_loss(datum/source)
	SIGNAL_HANDLER
	updatehealth()

/mob/living/carbon/human/proc/on_lose_noblood_trait(datum/source)
	SIGNAL_HANDLER
	blood_volume = clamp(blood_volume, BLOOD_VOLUME_NORMAL, BLOOD_VOLUME_MAXIMUM - 1)

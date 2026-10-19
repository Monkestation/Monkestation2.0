//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting


/mob/living/carbon/IsParalyzed(include_stamcrit = TRUE)
	return ..() || (include_stamcrit && HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))

/mob/living/proc/stamina_stun()
	return

/mob/living/proc/exit_stamina_stun()
	SIGNAL_HANDLER
	return

/mob/living/carbon/stamina_stun()
	if(HAS_TRAIT(src, TRAIT_CANT_STAMCRIT))
		return //baton resistance can't stam crit but can still be non sprinted
	if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA)) //Already in stamcrit
		return
	if(check_stun_immunity(CANKNOCKDOWN))
		return
	visible_message(
		span_danger("[src] slumps over, too weak to continue fighting..."),
		span_userdanger("You're too exhausted to continue fighting..."),
		span_hear("You hear something hit the floor.")
	)
	ADD_TRAIT(src, TRAIT_INCAPACITATED, STAMINA)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAMINA)
	ADD_TRAIT(src, TRAIT_FLOORED, STAMINA)
	filters += FILTER_STAMINACRIT
	SEND_SIGNAL(src, COMSIG_LIVING_STAMINA_STUN)

	addtimer(CALLBACK(src, PROC_REF(exit_stamina_stun)), STAMINA_STUN_TIME)
	stamina.stop()

/mob/living/carbon/exit_stamina_stun()
	if(!HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA)) //Not in stamcrit currently
		return

	REMOVE_TRAIT(src, TRAIT_INCAPACITATED, STAMINA)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, STAMINA)
	REMOVE_TRAIT(src, TRAIT_FLOORED, STAMINA)
	filters -= FILTER_STAMINACRIT

	stamina.resume()
	if (stamina.current < 15)
		stamina.adjust(15 - stamina.current) //Brings you up to at least 15 stamina after exiting stamcrit - you will still be in stamina damage slowdown for about 5 seconds

/mob/living/carbon/adjust_disgust(amount)
	disgust = clamp(disgust+amount, 0, DISGUST_LEVEL_MAXEDOUT)

/mob/living/carbon/set_disgust(amount)
	disgust = clamp(amount, 0, DISGUST_LEVEL_MAXEDOUT)


////////////////////////////////////////TRAUMAS/////////////////////////////////////////

/mob/living/carbon/proc/get_traumas(ignore_flags = NONE)
	. = list()
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	for(var/datum/brain_trauma/trauma as anything in brain?.traumas)
		if(!(trauma.trauma_flags & ignore_flags))
			. += trauma

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience, ignore_flags = NONE)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	return brain?.has_trauma_type(brain_trauma_type, resilience, ignore_flags)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		var/list/arguments = list()
		if(args.len > 2)
			arguments = args.Copy(3)
		return brain.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	return brain?.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, ignore_flags = NONE)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	return brain?.cure_trauma_type(brain_trauma_type, resilience, ignore_flags)

/mob/living/carbon/proc/cure_all_traumas(resilience, ignore_flags = NONE)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	return brain?.cure_all_traumas(resilience, ignore_flags)

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "regrow_limb"
	button_icon = SLIME_ACTIONS_ICON_FILE
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/user = owner
	var/list/limbs_to_heal = user.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	return user.blood_volume >= BLOOD_VOLUME_OKAY+40

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/user = owner
	var/list/limbs_to_heal = user.get_missing_limbs()
	if(!length(limbs_to_heal))
		to_chat(user, span_notice("You feel intact enough as it is."))
		return
	to_chat(user, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(!do_after(user, 2 SECONDS))
		return
	if(user.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		user.regenerate_limbs()
		if(BODY_ZONE_HEAD in limbs_to_heal)
			regrow_eyes(user)
		user.blood_volume -= 40*length(limbs_to_heal)
		to_chat(user, span_notice("...and after a moment you finish reforming!"))
		return
	else if(user.blood_volume >= 40)//We can partially heal some limbs
		while(user.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			user.regenerate_limb(healed_limb)
			if(healed_limb == BODY_ZONE_HEAD)
				regrow_eyes(user)
			limbs_to_heal -= healed_limb
			user.blood_volume -= 40
		to_chat(user, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(user, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

/datum/action/innate/regenerate_limbs/proc/regrow_eyes(mob/living/carbon/human/user)
	if(!istype(user.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/oozeling))
		return
	var/obj/item/organ/new_eyes = user.dna.species.get_mutant_organ_type_for_slot(ORGAN_SLOT_EYES)
	new_eyes = SSwardrobe.provide_type(new_eyes)
	new_eyes.Insert(user)

/// REGENERATE LIMBS
/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(update_status_on_signal))

/datum/action/innate/regenerate_limbs/Remove(mob/removed_from)
	if(!isnull(removed_from))
		UnregisterSignal(removed_from, COMSIG_HUMAN_ON_HANDLE_BLOOD)
	return ..()

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	var/obj/item/organ/new_organ
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(!do_after(H, 2 SECONDS))
		return
	if(H.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		if((BODY_ZONE_HEAD in limbs_to_heal) && istype(H.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/oozeling)) // We have a head now so we should make eyes.
			new_organ = H.dna.species.get_mutant_organ_type_for_slot(ORGAN_SLOT_EYES)
			new_organ = SSwardrobe.provide_type(new_organ)
			new_organ.Insert(H)
		H.blood_volume -= 40*length(limbs_to_heal)
		to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			if(istype(H.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/oozeling)) // We have a head now so we should make eyes.
				new_organ = H.dna.species.get_mutant_organ_type_for_slot(ORGAN_SLOT_EYES)
				new_organ = SSwardrobe.provide_type(new_organ)
				new_organ.Insert(H)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

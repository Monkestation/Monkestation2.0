/obj/item/organ/internal/heart/clockwork //this heart doesnt have the fancy bits normal cyberhearts do. However, it also doesnt fucking kill you when EMPd
	name = "biomechanical pump"
	desc = "A complex, multi-valved hydraulic pump, which fits perfectly where a heart normally would."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "heart-clock"
	organ_flags = ORGAN_ROBOTIC

///The rate at which slimes regenerate their jelly normally
#define JELLY_REGEN_RATE 1.5
///The rate at which slimes regenerate their jelly when they completely run out of it and start taking damage, usually after having cannibalized all their limbs already
#define JELLY_REGEN_RATE_EMPTY 2.5
///The blood volume at which slimes begin to start losing nutrition -- so that IV drips can work for blood deficient slimes
#define BLOOD_VOLUME_LOSE_NUTRITION 550


/obj/item/organ/internal/heart/slime
	name = "slime heart"

	heart_bloodtype = /datum/blood_type/slime
	/// Ability given to the owner of the organ
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	/// Ability given to the owner of the organ
	var/datum/action/innate/retract_limb/retract_limb

/obj/item/organ/internal/heart/slime/Destroy()
	QDEL_NULL(regenerate_limbs)
	QDEL_NULL(retract_limb)
	return ..()

/obj/item/organ/internal/heart/slime/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(QDELETED(regenerate_limbs))
		regenerate_limbs = new
	regenerate_limbs.Grant(receiver)
	if(QDELETED(retract_limb))
		retract_limb = new
	retract_limb.Grant(receiver)
	RegisterSignal(receiver, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(slime_blood))

/obj/item/organ/internal/heart/slime/Remove(mob/living/carbon/heartless, special)
	. = ..()
	QDEL_NULL(regenerate_limbs)
	QDEL_NULL(retract_limb)
	UnregisterSignal(heartless, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/obj/item/organ/internal/heart/slime/proc/slime_blood(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(slime.stat == DEAD)
		return NONE

	. = HANDLE_BLOOD_NO_NUTRITION_DRAIN|HANDLE_BLOOD_NO_EFFECTS

	if(slime.blood_volume <= 0)
		slime.blood_volume += JELLY_REGEN_RATE_EMPTY * seconds_per_tick
		slime.adjustBruteLoss(2.5 * seconds_per_tick)
		to_chat(slime, span_danger("You feel empty!"))

	if(slime.blood_volume < BLOOD_VOLUME_NORMAL)
		if(slime.nutrition >= NUTRITION_LEVEL_STARVING)
			slime.blood_volume += JELLY_REGEN_RATE * seconds_per_tick
			if(slime.blood_volume <= BLOOD_VOLUME_LOSE_NUTRITION) // don't lose nutrition if we are above a certain threshold, otherwise slimes on IV drips will still lose nutrition
				slime.adjust_nutrition(-1.25 * seconds_per_tick)

	if(HAS_TRAIT(slime, TRAIT_BLOOD_DEFICIENCY))
		var/datum/quirk/blooddeficiency/blooddeficiency = slime.get_quirk(/datum/quirk/blooddeficiency)
		blooddeficiency?.lose_blood(slime, seconds_per_tick)

	if(slime.blood_volume < BLOOD_VOLUME_OKAY)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(slime, span_danger("You feel drained!"))

	if(slime.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(slime)

	regenerate_limbs?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	return .

/obj/item/organ/internal/heart/slime/proc/Cannibalize_Body(mob/living/carbon/human/body)
	if(HAS_TRAIT(body, TRAIT_OOZELING_NO_CANNIBALIZE))
		return
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - body.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!length(limbs_to_consume))
		body.losebreath++
		return
	if(body.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = body.get_bodypart(pick(limbs_to_consume))
	for(var/obj/item/organ/internal/organ in body.get_organs_for_zone(consumed_limb.body_zone))
		organ.Remove(body)
		if(!QDELETED(organ))
			organ.forceMove(body.drop_location())
	consumed_limb.drop_limb()
	to_chat(body, span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	body.blood_volume += 20

/// REGENERATE LIMBS
/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

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

/**
 * Allows oozelings to selectively retract a limb.
 */
/datum/action/innate/retract_limb
	name = "Retract Limb"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "retract_limb"
	button_icon = SLIME_ACTIONS_ICON_FILE
	background_icon_state = "bg_alien"

/datum/action/innate/retract_limb/IsAvailable(feedback)
	. = ..()
	if(!.)
		return
	if(!isoozeling(owner))
		return
	var/mob/living/carbon/human/user = owner
	var/list/limbs = list(user.get_bodypart(BODY_ZONE_R_ARM), user.get_bodypart(BODY_ZONE_L_ARM), user.get_bodypart(BODY_ZONE_R_LEG), user.get_bodypart(BODY_ZONE_L_LEG))
	if(!length(limbs))
		return FALSE // What are you gonna eat if there's nothing left?
	return TRUE

/datum/action/innate/retract_limb/Activate()
	. = ..()
	if(!isoozeling(owner))
		return
	var/mob/living/carbon/human/user = owner
	var/list/possible_limbs = list(BODY_ZONE_HEAD, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	if(!isnull(user.handcuffed))
		possible_limbs -= list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	if(!isnull(user.legcuffed))
		possible_limbs -= list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/retractable_limbs = list()
	for(var/zone as anything in possible_limbs)
		var/obj/item/bodypart/limb = user.get_bodypart(zone)
		if(!isnull(limb))
			retractable_limbs[limb] = limb.appearance
	if(!length(retractable_limbs))
		return
	var/obj/item/bodypart/selected_limb = show_radial_menu(user, user, retractable_limbs)
	if(isnull(selected_limb))
		return
	for(var/obj/item/organ/internal/organ in user.get_organs_for_zone(selected_limb.body_zone))
		organ.Remove(user)
		if(!QDELETED(organ))
			organ.forceMove(user.drop_location())
	selected_limb.drop_limb()
	qdel(selected_limb)
	user.blood_volume += 20
	playsound(user, 'sound/items/eatfood.ogg', 20, TRUE)

#undef JELLY_REGEN_RATE
#undef JELLY_REGEN_RATE_EMPTY
#undef BLOOD_VOLUME_LOSE_NUTRITION

/obj/item/organ/internal/heart/synth
	name = "hydraulic pump engine"
	desc = "An electronic device that handles the hydraulic pumps, powering one's robotic limbs. Without this, synthetics are unable to move."
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "heart-ipc-on"
	base_icon_state = "heart-ipc"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD // 1.5x due to synthcode.tm being weird
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART
	var/last_message_time = 0

/obj/item/organ/internal/heart/synth/emp_act(severity)
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Main hydraulic pump control has taken severe damage, seek maintenance immediately. Error code: HP300-10."))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maximum = maxHealth, required_organ_flag = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Main hydraulic pump control has taken light damage, seek maintenance immediately. Error code: HP300-05."))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maximum = maxHealth, required_organ_flag = ORGAN_ROBOTIC)

/datum/design/synth_heart
	name = "Hydraulic Pump Engine"
	desc = "An electronic device that handles the hydraulic pumps, powering one's robotic limbs. Without this, synthetics are unable to move."
	id = "synth_heart"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/heart/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

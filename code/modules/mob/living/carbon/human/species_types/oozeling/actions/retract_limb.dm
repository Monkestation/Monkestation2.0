/**
 * Allows oozelings to selectively retract a limb.
 */
/datum/action/innate/retract_limb
	name = "Retract Limb"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
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
	for(var/zone in possible_limbs)
		var/obj/item/bodypart/limb = user.get_bodypart(zone)
		if(!isnull(limb))
			retractable_limbs[limb] = limb.appearance
	if(!length(retractable_limbs))
		return
	var/obj/item/bodypart/selected_limb = show_radial_menu(user, user, retractable_limbs)
	if(isnull(selected_limb))
		return
	if(!do_after(user, 2 SECONDS))
		selected_limb.balloon_alert(user, "focus interrupted!")
		return
	for(var/obj/item/organ/internal/organ in user.get_organs_for_zone(selected_limb.body_zone))
		organ.Remove(user)
		if(!QDELETED(organ))
			organ.forceMove(user.drop_location())
	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	var/brute = selected_limb.brute_dam
	var/burn = selected_limb.burn_dam
	selected_limb.drop_limb()
	user.visible_message(
		span_warning("[user]'s [selected_limb] is retracted into [user.p_their()] body with a quick, deliberate motion!"),
		span_notice("You retract your [selected_limb] back into your body."),
	)
	qdel(selected_limb)
	chest?.receive_damage(brute, burn, forced = TRUE, wound_bonus = CANT_WOUND)
	user.blood_volume += 20
	playsound(user, 'sound/items/eatfood.ogg', 20, TRUE)

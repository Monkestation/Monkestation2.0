/datum/action/cooldown/mob_cooldown/bloodling/devour
	name = "Devour Limb"
	desc = "Allows you to consume a creatures limb. Sets ALL your abilities on a 10 second cooldown"
	button_icon_state = "devour"
	cooldown_time = 10 SECONDS

/datum/action/cooldown/mob_cooldown/bloodling/devour/PreActivate(atom/target)
	. = ..()
	var/mob/living/mob = target
	if(!iscarbon(mob))
		owner.balloon_alert(owner, "only works on carbons!")
		return FALSE
	return

/datum/action/cooldown/mob_cooldown/bloodling/devour/Activate(atom/target)
	. = ..()
	StartCooldown()
	var/mob/living/basic/bloodling/our_mob = owner
	var/list/candidate_for_removal = list()
	var/mob/living/carbon/carbon_target = target

	// Loops over the limbs of our target carbon, this is so stuff like the head, chest or unremovable body parts arent destroyed
	for(var/obj/item/bodypart/bodypart in carbon_target.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_HEAD)
			continue
		if(bodypart.body_zone == BODY_ZONE_CHEST)
			continue
		if(bodypart.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		candidate_for_removal += bodypart.body_zone

	if(!length(candidate_for_removal))
		return FALSE

	var/limb_to_remove = pick(candidate_for_removal)
	var/obj/item/bodypart/target_part = carbon_target.get_bodypart(limb_to_remove)

	if(isnull(target_part))
		return FALSE

	target_part.dismember()
	qdel(target_part)
	our_mob.add_biomass(15)

	our_mob.visible_message(
		span_alertalien("[our_mob] snaps its maw over [target]s [target_part] and swiftly devours it!"),
		span_noticealien("You devour [target]s [target_part]!"),
	)
	playsound(our_mob, 'sound/magic/demon_attack1.ogg', 80)
	return TRUE

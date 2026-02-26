/datum/action/cooldown/bloodling/devour
	name = "Devour Limb"
	desc = "Allows you to randomly consume a creatures limb, they must be still for 1 second for this process. Sets ALL your abilities on a 5 second cooldown"
	button_icon_state = "devour"
	cooldown_time = 5 SECONDS
	cast_range

/datum/action/cooldown/bloodling/devour/PreActivate(atom/target)

	var/mob/living/mob = target
	if(get_dist(usr, target) > 1)
		owner.balloon_alert(owner, "too Far!")
		return FALSE
	if(!iscarbon(mob))
		owner.balloon_alert(owner, "only works on carbons!")
		return FALSE
	..()

/datum/action/cooldown/bloodling/devour/Activate(atom/target)
	var/mob/living/basic/bloodling/our_mob = owner
	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/target_part = find_limb(carbon_target)
	if(!target_part)
		return FALSE

	our_mob.visible_message(
		span_alertalien("[our_mob] holds its maw over [target]s [target_part] and prepares to devour it!"),
		span_noticealien("You prepare to devour [target]s [target_part]!"),
	)

	if(!do_after(owner, 1 SECOND, carbon_target))
		to_chat(our_mob, span_noticealien("They flee before you can snap your jaws..."))
		return FALSE

	target_part.dismember()
	qdel(target_part)
	our_mob.add_biomass(4)
	..()
	our_mob.visible_message(
		span_alertalien("[our_mob] snaps its maw over [target]s [target_part] and swiftly devours it!"),
		span_noticealien("You devour [target]s [target_part]!"),
	)
	playsound(our_mob, 'sound/magic/demon_attack1.ogg', 80)
	StartCooldownOthers(5 SECONDS)
	return TRUE

/datum/action/cooldown/bloodling/devour/proc/find_limb(mob/living/carbon/carbon_target)
	if(HAS_TRAIT(carbon_target, TRAIT_GODMODE))
		return FALSE
	if(HAS_TRAIT(carbon_target, TRAIT_NODISMEMBER))
		return FALSE

	var/list/candidate_for_removal = list()
	// Loops over the limbs of our target carbon, this is so stuff like the head, chest or unremovable body parts arent destroyed
	for(var/obj/item/bodypart/bodypart in carbon_target.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_HEAD)
			continue
		if(bodypart.body_zone == BODY_ZONE_CHEST)
			continue
		if(bodypart.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		if(isnull(bodypart))
			continue
		candidate_for_removal += bodypart.body_zone

	if(!length(candidate_for_removal))
		to_chat(owner, span_noticealien("They have no more limbs..."))
		return FALSE

	var/limb_to_remove = pick(candidate_for_removal)
	var/obj/item/bodypart/target_part = carbon_target.get_bodypart(limb_to_remove)

	return target_part

/**
 *	# Obfuscation
 *
 *	Level 1 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 2 tile)
 *	Level 2 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 3 tiles)
 *	Level 3 - Cloak of Darkness until clicking an area, teleports the user to the selected area
 *	Level 4 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to bleed.
 *	Level 5 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to fall asleep.
 */

#define OBFUSCATION_BLOOD_COST_PER_TILE 5
#define OBFUSCATION_BLEED_LEVEL 4
#define OBFUSCATION_KNOCKDOWN_LEVEL 5
#define OBFUSCATION_ANYWHERE_LEVEL 6
/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation
	name = "Obfuscation"
	level_current = 1
	button_icon_state = "power_obfuscation"
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = TREMERE_CAN_BUY
	bloodcost = 10
	sol_multiplier = 4
	constant_bloodcost = 2
	cooldown_time = 12 SECONDS
	target_range = 2
	power_activates_immediately = FALSE
	prefire_message = "Right click to teleport"

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/on_power_upgrade()
	// 1 + for default, the other + is for the upgrade that hasn't been added yet.
	if(level_current >= OBFUSCATION_ANYWHERE_LEVEL)
		target_range = 0
	else
		target_range = min(level_current + 2, 10)
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/get_power_desc_extended()
	. = "Hide yourself within a Cloak of Darkness, click on a tile to teleport"
	. = "Costs [OBFUSCATION_BLOOD_COST_PER_TILE] blood per tile teleported."
	if(target_range)
		. += " up to [target_range] tiles away."
	else
		. += " anywhere you can see."
	if(level_current >= OBFUSCATION_BLEED_LEVEL)
		if(level_current >= OBFUSCATION_KNOCKDOWN_LEVEL)
			. += " This will cause people at your destination to start bleeding and fall asleep."
		else
			. += " This will cause people at your destination to start bleeding."

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/get_power_explanation_extended()
	. = list()
	. += "When Activated, you will be hidden in a Cloak of Darkness."
	. += "[target_range ? "Click to teleport up to [target_range] tiles away, as long as you can see it" : "You can teleport anywhere you can see"]."
	. += "Teleporting will refill your stamina to full."
	. += "At level [OBFUSCATION_BLEED_LEVEL] you will cause people at your end location to start bleeding."
	. += "At level [OBFUSCATION_KNOCKDOWN_LEVEL] you will cause people at your end location to be knocked down."
	. += "At level [OBFUSCATION_ANYWHERE_LEVEL] you will be able to teleport anywhere, even if you cannot properly see the tile."
	. += "The power will cost [OBFUSCATION_BLOOD_COST_PER_TILE] blood per tile that you teleport."

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(target_atom))
		return FALSE
	var/turf/target_turf = target_atom
	if(target_turf.is_blocked_turf_ignore_climbable())
		return FALSE
	if(level_current < OBFUSCATION_ANYWHERE_LEVEL && !(target_turf in view(owner.client.view, owner.client)))
		owner.balloon_alert(owner, "out of view!")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/ActivatePower(trigger_flags)
	..()
	ADD_TRAIT(owner, TRAIT_UNKNOWN, REF(src))
	owner.AddElement(/datum/element/digitalcamo)
	animate(owner, alpha = 15, time = 2 SECONDS)

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/DeactivatePower(deactivate_flags)
	..()
	REMOVE_TRAIT(owner, TRAIT_UNKNOWN, REF(src))
	animate(owner, alpha = 255, time = 2 SECONDS)
	owner.RemoveElement(/datum/element/digitalcamo)

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/FireTargetedPower(atom/target_atom)
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/FireSecondaryTargetedPower(atom/target, params)
	. = ..()
	var/mob/living/user = owner
	var/turf/targeted_turf = get_turf(target)
	obfuscation_blink(user, targeted_turf)
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/obfuscation/proc/obfuscation_blink(mob/living/user, turf/targeted_turf)
	var/blood_cost = min(OBFUSCATION_BLOOD_COST_PER_TILE * get_dist(user, targeted_turf), 100)
	if(!can_pay_cost(blood_cost))
		owner.balloon_alert(owner, "not enough blood!")
		return
	playsound(user, 'sound/magic/summon_karp.ogg', 60)
	playsound(targeted_turf, 'sound/magic/summon_karp.ogg', 60)

	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(user.drop_location())
	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(targeted_turf)

	for(var/mob/living/carbon/living_mob in range(1, targeted_turf)-user)
		if(IS_BLOODSUCKER(living_mob) || IS_VASSAL(living_mob))
			continue
		if(level_current >= OBFUSCATION_BLEED_LEVEL)
			var/obj/item/bodypart/bodypart = pick(living_mob.bodyparts)
			var/severity = pick(WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_CRITICAL)
			living_mob.cause_wound_of_type_and_severity(WOUND_SLASH, bodypart, severity, wound_source = "obfuscation")
			living_mob.adjustBruteLoss(15)
		if(level_current >= OBFUSCATION_KNOCKDOWN_LEVEL)
			living_mob.Knockdown(10 SECONDS, ignore_canstun = TRUE)

	do_teleport(owner, targeted_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	user.stamina.revitalize()
	power_activated_sucessfully(cost_override = blood_cost)

#undef OBFUSCATION_BLOOD_COST_PER_TILE
#undef OBFUSCATION_BLEED_LEVEL
#undef OBFUSCATION_KNOCKDOWN_LEVEL
#undef OBFUSCATION_ANYWHERE_LEVEL

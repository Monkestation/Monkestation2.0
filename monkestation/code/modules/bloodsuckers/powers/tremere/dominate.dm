/**
 *	# Dominate;
 *
 *	Level 1 - Mesmerizes and mutes target
 *	Level 2 - Can mesmerize OR use on a crit or dead target to revive as a temporary Vassal for 5 minutes before dying.
 *	Level 3 - Same as above but gives x-ray vision while toggled ready
 *	Level 4 - Temporary vassals will no longer be soft-spoken/hard of hearing
 */

#define TEMP_VASSALIZE_COST 150
#define DOMINATE_VASSALIZE_LEVEL 2
#define DOMINATE_XRAY_LEVEL 3
#define DOMINATE_NON_MUTE_VASSALIZE_LEVEL 4

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate
	name = "Dominate"
	button_icon_state = "power_auspex"
	background_icon_state = "tremere_power_off"
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	button_icon = 'monkestation/icons/bloodsuckers/actions_tremere_bloodsucker.dmi'
	background_icon = 'monkestation/icons/bloodsuckers/actions_tremere_bloodsucker.dmi'
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	level_current = 1
	button_icon_state = "power_dominate"
	purchase_flags = TREMERE_CAN_BUY
	bloodcost = 15
	constant_bloodcost = 0.1
	target_range = 5
	mesmerize_delay = 4 SECONDS
	blind_at_level = 3
	blocked_by_glasses = FALSE
	/// Data huds to show while the power is active
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED)
	/// assoc list of timer_id to vassal datum
	var/list/vassals = list()
	var/vassal_creation_time = 6 SECONDS

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/Remove(mob/removed_from)
	. = ..()
	for(var/datum/antagonist/thrall as anything in vassals)
		end_possession(thrall)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/get_power_desc_extended()
	. = ..()
	if(level_current >= DOMINATE_VASSALIZE_LEVEL)
		. += "If your target is in critical condition or dead, they will instead be turned into a temporary Vassal. This will cost [TEMP_VASSALIZE_COST] blood. Pre-existing dead ghouls will simply be revived. This also works on Oozeling cores."

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/get_power_explanation_extended()
	. = list()
	. += "Click any person to, after [DisplayTimeText(mesmerize_delay)], stun them for [DisplayTimeText(get_power_time())]."
	. += "Casting [src] will completely immobilize, and blind them for the next [DisplayTimeText(get_power_time())], and will also mute them for [DisplayTimeText(get_power_time())]."
	. += "While this ability is active, you will be able to see additional information about everyone in the room."
	. += "At level [DOMINATE_XRAY_LEVEL], you will gain X-Ray vision while this ability is active."
	. += "At level [DOMINATE_VASSALIZE_LEVEL], while adjacent to the target, if your target is in critical condition or dead, they will instead be turned into a temporary Vassal. This will cost [TEMP_VASSALIZE_COST] blood."
	. += "The victim must have atleast [BLOOD_VOLUME_BAD] blood to be ghouled."
	. += "The vassal will be unable to talk and hear well if the level of [src] is not at least [DOMINATE_NON_MUTE_VASSALIZE_LEVEL]"
	. += "If you use this on a currently dead normal Vassal, they will will not suddenly cease to live as if a temporary Vassal."
	. += "They will have complete loyalty to you, until their death in [DisplayTimeText(get_vassal_duration())] upon use."
	. += "Vassalizing or reviving a vassal will make this ability go on cooldown for [DisplayTimeText(get_vassalize_cooldown())]."
	. += "This also works on Oozeling cores."

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/CheckValidTarget(atom/target_atom)
	// oozeling cores have special snowflake checks
	if(!is_oozeling_core(target_atom))
		return ..()
	var/obj/item/organ/internal/brain/slime/oozeling_core = target_atom
	if(level_current >= DOMINATE_VASSALIZE_LEVEL && oozeling_core.mind)
		return TRUE
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/CheckCanTarget(atom/target_atom)
	var/mob/living/selected_target = target_atom
	if(level_current >= DOMINATE_VASSALIZE_LEVEL || (!is_oozeling_core(selected_target) && selected_target.stat >= SOFT_CRIT))
		if(selected_target?.mind && owner.Adjacent(selected_target))
			return TRUE
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/ContinueActive(mob/living/user, mob/living/target)
	if(!target)
		return can_use(user)
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/ActivatePower(atom/target)
	. = ..()
	if(level_current >= DOMINATE_XRAY_LEVEL)
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, DOMINATE_TRAIT)
	for(var/hudtype in datahuds)
		var/datum/atom_hud/data_hud = GLOB.huds[hudtype]
		data_hud.show_to(owner)
	owner.update_sight()

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/DeactivatePower(deactivate_flags)
	..()
	if(level_current >= DOMINATE_XRAY_LEVEL)
		REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, DOMINATE_TRAIT)
	for(var/hudtype in datahuds)
		var/datum/atom_hud/data_hud = GLOB.huds[hudtype]
		data_hud.hide_from(owner)
	owner.update_sight()

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/FireTargetedPower(atom/target, params)
	var/mob/living/target_mob = target
	var/mob/living/user = owner
	user.face_atom(target)
	if((is_oozeling_core(target) || target_mob.stat != CONSCIOUS) && level_current >= DOMINATE_VASSALIZE_LEVEL)
		if(user.Adjacent(target))
			attempt_ghoulize(target, user)
			return TRUE
		else
			if(IS_VASSAL(target_mob))
				owner.balloon_alert(owner, "too far to revive!")
			else
				owner.balloon_alert(owner, "too far to vassal!")
			return TRUE
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/attempt_ghoulize(mob/living/target, mob/living/user)
	owner.face_atom(target)
	var/datum/antagonist/vassal/vassal = IS_VASSAL(target)
	if(!victim_has_blood(target))
		return FALSE
	if(vassal)
		owner.balloon_alert(owner, "attempting to revive.")
	else
		if(!bloodsuckerdatum_power.can_make_vassal(target))
			return FALSE
		owner.balloon_alert(owner, "attempting to vassalize.")
	if(!do_after(user, vassal_creation_time, target, NONE, TRUE, hidden = TRUE))
		return FALSE
	if(!victim_has_blood(target))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		owner.balloon_alert(owner, "their body refuses to react...")
		return FALSE
	if(target?.mind?.dnr)
		owner.balloon_alert(owner, "there's no soul...")
		return FALSE
	if(vassal?.master == bloodsuckerdatum_power)
		if(is_oozeling_core(target))
			var/obj/item/organ/internal/brain/slime/oozeling_core = target
			target = oozeling_core.rebuild_body(nugget = FALSE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
			if(QDELETED(target))
				owner.balloon_alert(owner, "we fail to rebuild [oozeling_core]...")
				return FALSE
		else
			if(target.stat != DEAD)
				owner.balloon_alert(owner, "not dead!")
				return FALSE
			target.mind?.grab_ghost()
			target.revive(ADMIN_HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
		power_activated_sucessfully(cost_override = TEMP_VASSALIZE_COST, cooldown_override = get_vassalize_cooldown())
		to_chat(user, span_warning("We revive [target]!"))
		owner.balloon_alert(owner, "successfully revived!")
		log_combat(owner, target, "tremere revived", addition = "Revived their vassal using dominate")
		return FALSE
	var/datum/antagonist/vassal/vassal_datum = bloodsuckerdatum_power.make_vassal(target, TREMERE_VASSAL) //don't turn them into a favorite please
	if(!vassal_datum)
		owner.balloon_alert(owner, "not a valid target for vassalizing!")
		return FALSE
	if(is_oozeling_core(target))
		var/obj/item/organ/internal/brain/slime/oozeling_core = target
		target = oozeling_core.rebuild_body(nugget = FALSE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
		if(QDELETED(target))
			owner.balloon_alert(owner, "we fail to rebuild [oozeling_core]...")
			return FALSE
	else
		// no escaping at this point
		target.mind?.grab_ghost(TRUE)
		target.revive(ADMIN_HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	INVOKE_ASYNC(vassal_datum, TYPE_PROC_REF(/datum, ui_interact), target) // make sure they see the vassal popup!!
	power_activated_sucessfully(cost_override = TEMP_VASSALIZE_COST, cooldown_override = get_vassalize_cooldown())
	to_chat(user, span_warning("We revive [target]!"))

	//Remove mindshield if they have one
	for(var/obj/item/implant/implant as anything in target.implants)
		if(istype(implant, /obj/item/implant/mindshield) && implant.removed(target, silent = TRUE))
			qdel(implant)

	var/living_time = get_vassal_duration()
	log_combat(owner, target, "tremere mindslaved", addition = "Revived and converted [target] into a temporary tremere vassal for [DisplayTimeText(living_time)].")
	if(level_current <= DOMINATE_NON_MUTE_VASSALIZE_LEVEL)
		target.add_traits(list(TRAIT_SOFTSPOKEN, TRAIT_HARD_OF_HEARING), DOMINATE_TRAIT)
	user.balloon_alert(target, "only [DisplayTimeText(living_time)] left to live!")
	to_chat(target, span_warning("You will only live for [DisplayTimeText(living_time)]! Obey your master and go out in a blaze of glory!"))
	var/timer_id = addtimer(CALLBACK(src, PROC_REF(end_possession), vassal_datum), living_time, TIMER_STOPPABLE)
	// timer that only the master and thrall can see
	setup_timer(user, target, living_time, timer_id)
	vassals[vassal_datum] = timer_id
	RegisterSignals(target, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	RegisterSignal(target.mind, COMSIG_ANTAGONIST_REMOVED, PROC_REF(on_antag_datum_removal))
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/victim_has_blood(mob/living/target)
	// oozeling cores don't have blood volume anyways
	if(is_oozeling_core(target))
		return TRUE
	// you can always revive non-temporary vassal
	if(IS_VASSAL(target))
		return TRUE
	if(target.blood_volume < BLOOD_VOLUME_BAD)
		owner.balloon_alert(owner, "not enough blood in victim!")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/setup_timer(mob/living/user, mob/living/target, living_time, timer_id)
	var/list/show_to = list(user)
	if(bloodsuckerdatum_power && length(bloodsuckerdatum_power.vassals))
		for(var/datum/antagonist/vassal in bloodsuckerdatum_power.vassals)
			if(isnull(vassal?.owner?.current))
				continue
			show_to |= vassal.owner.current

	new /atom/movable/screen/text/screen_timer/attached(null, show_to, timer_id, "Dies in ${timer}", -16, 32, target)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/on_antag_datum_removal(datum/mind/mind, datum/antagonist/vassal)
	end_possession(vassal, FALSE)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/on_death(mob/living/thrall)
	var/vassal = IS_VASSAL(thrall)
	if(isnull(vassal))
		return
	end_possession(vassal)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/end_possession(datum/antagonist/vassal, remove_antag = TRUE)
	SIGNAL_HANDLER
	if(!vassals[vassal])
		return
	if(!istype(vassal))
		CRASH("[src] end_possession called with non-vassal [vassal]!")
	var/mob/living/user = vassal?.owner?.current
	var/vassal_timer = vassals[vassal]
	if(!istype(user))
		vassals -= vassal
		return
	if(vassal_timer)
		deltimer(vassal_timer)
	user.remove_traits(list(TRAIT_SOFTSPOKEN, TRAIT_HARD_OF_HEARING), DOMINATE_TRAIT)
	UnregisterSignal(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	UnregisterSignal(user.mind, COMSIG_ANTAGONIST_REMOVED)
	if(!HAS_TRAIT(user, TRAIT_NOBLOOD))
		user.blood_volume = 0
	to_chat(user, span_warning("You feel the Blood of your Master run out!"))
	vassals -= vassal
	if(remove_antag)
		user.mind?.remove_antag_datum(/datum/antagonist/vassal)
	if(user.stat == DEAD)
		return
	user.death()

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/get_vassal_duration()
	return min(2 MINUTES * max(level_current, 1), 60 MINUTES - 1 SECOND)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/dominate/proc/get_vassalize_cooldown()
	return cooldown_time * 3

#undef TEMP_VASSALIZE_COST
#undef DOMINATE_XRAY_LEVEL
#undef DOMINATE_NON_MUTE_VASSALIZE_LEVEL

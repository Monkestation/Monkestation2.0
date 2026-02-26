#define BLOOD_LEVEL_GAIN_MAX 0.9
/datum/antagonist/bloodsucker/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER
	if(!examiner.mind)
		return
	var/info_to_display
	// Viewer is Target's Vassal?
	if(IS_VASSAL(examiner) in vassals)
		info_to_display = "This is your Master!"
	// Viewer not a Vamp AND not the target's vassal?
	else if(IS_BLOODSUCKER(examiner) || (broke_masquerade && HAS_MIND_TRAIT(examiner, TRAIT_OCCULTIST)))
		info_to_display = return_full_name()
	if(info_to_display)
		var/img_html = "<img class='icon' src='\ref['monkestation/icons/bloodsuckers/vampiric.dmi']?state=bloodsucker'></img>"
		examine_text += "\[" + span_warning("[img_html] <EM>[info_to_display]</EM>") + "\]"

///Called when a Bloodsucker buys a power: (power)
/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	for(var/datum/action/cooldown/bloodsucker/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power
	power.Grant(owner.current)
	log_uplink("[key_name(owner.current)] purchased [power].")
	return TRUE

///Called when a Bloodsucker loses a power: (power)
/datum/antagonist/bloodsucker/proc/RemovePower(datum/action/cooldown/bloodsucker/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

///When a Bloodsucker breaks the Masquerade, they get their HUD icon changed, and Malkavian Bloodsuckers get alerted.
/datum/antagonist/bloodsucker/proc/break_masquerade(mob/admin, silent = FALSE)
	if(broke_masquerade)
		return
	if(!silent)
		owner.current.playsound_local(null, 'monkestation/sound/bloodsuckers/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
		to_chat(owner.current, span_cultboldtalic("You have broken the Masquerade!"))
		to_chat(owner.current, span_warning("Bloodsucker Tip: When you break the Masquerade, you become open for termination by fellow Bloodsuckers, and your Vassals are no longer completely loyal to you, as other Bloodsuckers can steal them for themselves!"))
		SEND_GLOBAL_SIGNAL(COMSIG_BLOODSUCKER_BROKE_MASQUERADE, src)
	broke_masquerade = TRUE
	antag_hud_name = "masquerade_broken"
	add_team_hud(owner.current)

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/bloodsucker/proc/fix_masquerade(mob/admin)
	if(!broke_masquerade)
		return
	to_chat(owner.current, span_cultboldtalic("You have re-entered the Masquerade."))
	broke_masquerade = FALSE

/datum/antagonist/bloodsucker/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the Bloodsucker's Cause!"))

/datum/antagonist/bloodsucker/proc/RankUp()
	if(!owner?.current)
		return
	bloodsucker_level_unspent++
	owner.current.balloon_alert(owner.current, "you have grown more ancient!")
	if(!my_clan)
		to_chat(owner.current, span_notice("You have gained a rank. Join a Clan to spend it."))
		return
	// Spend Rank Immediately?
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		to_chat(owner, span_notice("<EM>You have grown more ancient! Sleep in a coffin (or put your Favorite Vassal on a persuasion rack for Ventrue) that you have claimed to thicken your blood and become more powerful.</EM>"))
		if(bloodsucker_level_unspent >= 2)
			to_chat(owner, span_announce("Bloodsucker Tip: If you cannot find or steal a coffin to use, you can build one from wood or metal."))
		return
	SpendRank()

/datum/antagonist/bloodsucker/proc/RankDown()
	bloodsucker_level_unspent--

/datum/antagonist/bloodsucker/proc/remove_nondefault_powers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(power.purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			continue
		RemovePower(power)

/datum/antagonist/bloodsucker/proc/LevelUpPowers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			continue
		power.upgrade_power()

///Disables all powers, accounting for torpor
/datum/antagonist/bloodsucker/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && is_in_torpor()))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/bloodsucker/proc/SpendRank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && bloodsucker_level_unspent <= 0))
		return
	SEND_SIGNAL(src, COMSIG_BLOODSUCKER_RANK_UP, target, cost_rank, blood_cost)

/**
 * Called when a Bloodsucker reaches Final Death
 * Releases all Vassals and gives them the ex_vassal datum.
 * Revenge vassals are handled separately by the COMSIG_BLOODSUCKER_FINAL_DEATH signal.
 */
/datum/antagonist/bloodsucker/proc/free_all_vassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		if(all_vassals.special_type == REVENGE_VASSAL)
			continue
		all_vassals.owner.add_antag_datum(/datum/antagonist/ex_vassal)
		all_vassals.owner.remove_antag_datum(/datum/antagonist/vassal)

// Blood level gain is used to give Bloodsuckers more levels if they are being aggressive and drinking from real, sentient people.
// The maximum blood that counts towards this
/datum/antagonist/bloodsucker/proc/blood_level_gain()
	var/level_cost = get_level_cost()
	// Checks if we have drunk enough blood from the living to allow us to gain a level up as well as checking if we have enough blood to actually use on the level up
	if(blood_level_gain < level_cost || bloodsucker_blood_volume < level_cost)
		return
	if(tgui_alert(owner.current, "You have drunk enough blood from the living to thicken your blood, this will cost you [level_cost] blood and give you another level", "Thicken your blood?", list("Yes", "No")) != "Yes") //asks user if they want to spend their blood on a level
		return
	// check again to make sure nothing weird has happened in between
	level_cost = get_level_cost()
	if(blood_level_gain < level_cost || bloodsucker_blood_volume < level_cost)
		to_chat(owner.current, span_warning("You no longer have enough living blood to thicken!"))
		return
	RankUp() // gives level
	blood_level_gain -= level_cost // Subtracts the cost from the pool of drunk blood
	AddBloodVolume(-level_cost) // Subtracts the cost from the bloodsucker's actual blood
	blood_level_gain_amount += 1 // Increments the variable that makes future levels more expensive

/datum/antagonist/bloodsucker/proc/get_level_cost()
	var/level_cost = (0.3 + (0.05 * blood_level_gain_amount))
	level_cost = min(level_cost, BLOOD_LEVEL_GAIN_MAX)
	level_cost = ((BLOODSUCKER_MAX_BLOOD_DEFAULT * 1.5) + (blood_level_gain_amount * BLOODSUCKER_MAX_BLOOD_INCREASE_ON_RANKUP)) * level_cost
	return level_cost

/// Animates the power icon above the vampire's head. Returns a reference to the icon to remove it later.
/atom/movable/proc/do_power_icon_animation(power_icon)
	var/mutable_appearance/alert = mutable_appearance('monkestation/icons/bloodsuckers/actions_bloodsucker.dmi', power_icon)
	SET_PLANE_EXPLICIT(alert, ABOVE_LIGHTING_PLANE, src)

	alert.layer = layer + 0.1

	var/atom/movable/flick_visual/visual = new()
	visual.appearance = alert
	visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	visual.alpha = 0

	src.vis_contents += visual

	animate(visual, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)

	LAZYADD(update_on_z, visual)

	return visual

/// Removes the power icon above the vampire's head.
/atom/movable/proc/remove_power_icon_animation(atom/movable/flick_visual/visual)
	LAZYREMOVE(update_on_z, visual)

	qdel(visual)

/**
 * CARBON INTEGRATION
 *
 * All overrides of mob/living and mob/living/carbon
 */
/// Brute
/mob/living/proc/getBruteLoss_nonProsthetic()
	return getBruteLoss()

/mob/living/carbon/getBruteLoss_nonProsthetic()
	if(dna?.species?.inherent_biotypes & MOB_ROBOTIC) // technically it's not a prosthetic if it's a "natural" part of their species
		return getBruteLoss()
	. = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		. += chosen_bodypart.brute_dam

/// Burn
/mob/living/proc/getFireLoss_nonProsthetic()
	return getFireLoss()

/mob/living/carbon/getFireLoss_nonProsthetic()
	if(dna?.species?.inherent_biotypes & MOB_ROBOTIC) // technically it's not a prosthetic if it's a "natural" part of their species
		return getFireLoss()
	. = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		. += chosen_bodypart.burn_dam

#undef BLOOD_LEVEL_GAIN_MAX

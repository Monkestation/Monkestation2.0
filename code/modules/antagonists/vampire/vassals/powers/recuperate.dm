/// Used by vassals
/datum/action/cooldown/vampire/recuperate
	name = "Sanguine Recuperation"
	desc = "Slowly heals you overtime using your master's blood, in exchange for some of your own blood and effort."
	button_icon_state = "power_recup"
	power_explanation = "Activating this Power will begin to heal your wounds.\n\
		You will heal Brute and Toxin damage at the cost of your Stamina and blood.\n\
		If you aren't a bloodless race, you will additionally heal Burn damage."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	special_flags = NONE
	vitaecost = 1.5
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/recuperate/can_use()
	. = ..()
	if(!.)
		return FALSE

	if(owner.stat >= DEAD || owner.incapacitated(IGNORE_RESTRAINTS))
		owner.balloon_alert(owner, "you are incapacitated...")
		return FALSE

/datum/action/cooldown/vampire/recuperate/activate_power()
	. = ..()
	to_chat(owner, span_notice("Your muscles clench as your master's immortal blood mixes with your own, knitting your wounds."))
	owner.balloon_alert(owner, "recuperate turned on.")

/datum/action/cooldown/vampire/recuperate/UsePower()
	. = ..()
	if(!. || !currently_active)
		return

	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	var/needs_update = FALSE
	carbon_owner.set_jitter_if_lower(10 SECONDS)
	carbon_owner.stamina?.adjust(-vitaecost * 1.1)
	needs_update += carbon_owner.adjustBruteLoss(-2.5, updating_health = FALSE)
	needs_update += carbon_owner.adjustToxLoss(-2, updating_health = FALSE, forced = TRUE)
	// Plasmamen won't lose blood, they don't have any, so they don't heal from Burn.
	if(!HAS_TRAIT(carbon_owner, TRAIT_NOBLOOD))
		carbon_owner.blood_volume -= vitaecost
		needs_update += carbon_owner.adjustFireLoss(-1.5, updating_health = FALSE)
	// Stop Bleeding
	//if(istype(carbon_owner) && carbon_owner.is_bleeding())
	//	carbon_owner.cauterise_wounds(-0.5)

	if(needs_update)
		carbon_owner.updatehealth()

/datum/action/cooldown/vampire/recuperate/continue_active()
	if(owner.stat == DEAD)
		return FALSE
	if(owner.incapacitated(IGNORE_RESTRAINTS))
		owner.balloon_alert(owner, "too exhausted...")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/recuperate/deactivate_power()
	owner.balloon_alert(owner, "recuperate turned off.")
	return ..()

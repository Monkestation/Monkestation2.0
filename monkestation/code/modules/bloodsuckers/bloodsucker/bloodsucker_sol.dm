/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/antagonist/bloodsucker/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		SSsol.can_fire = TRUE

/// End Sol, if you're the last Bloodsucker
/datum/antagonist/bloodsucker/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		SSsol.can_fire = FALSE

///Ranks the Bloodsucker up, called by Sol.
/datum/antagonist/bloodsucker/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_level < 3)
		INVOKE_ASYNC(src, PROC_REF(RankUp))
	else
		to_chat(owner.current, span_announce("You have already got as powerful as you can through surviving Sol."))

///Called when Sol is near starting.
/datum/antagonist/bloodsucker/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gohome)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/cooldown/bloodsucker/gohome/power in powers)
		RemovePower(power)

/// Cycle through all vamp antags and check if they're inside a closet.
/datum/antagonist/bloodsucker/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner?.current)
		return

	update_sunlight_hud()
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		owner.current.apply_status_effect(/datum/status_effect/bloodsucker_sol)
		return
	owner.current.remove_status_effect(/datum/status_effect/bloodsucker_sol)
	if(owner.current.am_staked() && COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
		to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
		COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	if(!is_in_torpor())
		check_begin_torpor(TRUE)
		owner.current.add_mood_event("vampsleep", /datum/mood_event/coffinsleep)

/datum/antagonist/bloodsucker/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(!owner || !owner.current)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'monkestation/sound/bloodsuckers/griffin_3.ogg', vol = 50, vary = TRUE)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'monkestation/sound/bloodsuckers/griffin_5.ogg', vol = 50, vary = TRUE)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', vol = 75, vary = TRUE)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', vol = 75, vary = TRUE)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/misc/ghosty_wind.ogg', vol = 90, vary = TRUE)

/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /handle_death()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/
/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	var/mob/living/carbon/user = owner.current
	if(QDELETED(user))
		return
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		torpor_begin()
		return
	if(user.has_status_effect(/datum/status_effect/frenzy))
		to_chat(user, span_userdanger("You are restless! Collect enough blood to end your frenzy."))
		return
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsol.sunlight_active && (total_damage >= 10 || typecached_item_in_list(user.organs, yucky_organ_typecache)) && !is_in_torpor())
		torpor_begin()

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	if(QDELETED(user))
		return
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return FALSE
	if(SSsol.sunlight_active)
		return FALSE
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			torpor_end()
	else
		if(total_brute <= 10)
			torpor_end()

/datum/antagonist/bloodsucker/proc/is_in_torpor()
	if(QDELETED(owner.current))
		return FALSE
	return HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TORPOR_TRAIT)

/datum/antagonist/bloodsucker/proc/torpor_begin()
	var/mob/living/current = owner.current
	if(QDELETED(current))
		return
	to_chat(current, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	// Force them to go to sleep
	REMOVE_TRAIT(current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	// Without this, you'll just keep dying while you recover.
	current.add_traits(torpor_traits, TORPOR_TRAIT)
	current.set_timed_status_effect(0 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// Disable ALL Powers
	DisableAllPowers()

/datum/antagonist/bloodsucker/proc/torpor_end()
	var/mob/living/current = owner.current
	if(QDELETED(current))
		return
	current.remove_status_effect(/datum/status_effect/bloodsucker_sol)
	current.grab_ghost()
	to_chat(current, span_warning("You have recovered from Torpor."))
	current.remove_traits(torpor_traits, TORPOR_TRAIT)
	if(!HAS_TRAIT(current, TRAIT_MASQUERADE))
		ADD_TRAIT(current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	heal_vampire_organs()
	current.pain_controller?.remove_all_pain()
	current.update_stat()
	SEND_SIGNAL(src, COMSIG_BLOODSUCKER_EXIT_TORPOR)

/datum/status_effect/bloodsucker_sol
	id = "bloodsucker_sol"
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodsucker_sol
	processing_speed = STATUS_EFFECT_PRIORITY
	/// The antag datum of the victim bloodsucker.
	var/datum/antagonist/bloodsucker/bloodsucker
	/// Is this bloodsucker currently protected from solar flares?
	var/protected = FALSE

/datum/status_effect/bloodsucker_sol/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(.) // alert gets created after on_apply, so we have to do an initial update_appearance here
		linked_alert?.update_appearance(UPDATE_ICON_STATE)

/datum/status_effect/bloodsucker_sol/on_apply()
	if(!SSsol.sunlight_active || istype(owner.loc, /obj/structure/closet/crate/coffin))
		return FALSE

	bloodsucker = IS_BLOODSUCKER(owner)
	if(!bloodsucker)
		. = FALSE // this ain't a vampire?!
		CRASH("[type] applied to non-bloodsucker ([owner]) somehow")

	update_in_shade()

	RegisterSignal(SSsol, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_SHADED), SIGNAL_REMOVETRAIT(TRAIT_SHADED)), PROC_REF(update_in_shade))

	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/bloodsucker_sol/on_remove()
	UnregisterSignal(SSsol, COMSIG_SOL_END)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, SIGNAL_ADDTRAIT(TRAIT_SHADED), SIGNAL_REMOVETRAIT(TRAIT_SHADED)))
	REMOVE_TRAITS_IN(owner, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bloodsucker_sol/tick(seconds_between_ticks)
	if(protected)
		return
	var/bloodsucker_level = bloodsucker.bloodsucker_level
	if(COOLDOWN_FINISHED(bloodsucker, bloodsucker_spam_sol_burn))
		if(bloodsucker_level > 0)
			to_chat(owner, span_userdanger("The solar flare sets your skin ablaze!"))
		else
			to_chat(owner, span_userdanger("The solar flare scalds your neophyte skin!"))
		COOLDOWN_START(bloodsucker, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	if(!HAS_TRAIT(owner, TRAIT_NOFIRE))
		if(owner.fire_stacks <= 0)
			owner.fire_stacks = 0
		if(bloodsucker_level > 0)
			owner.adjust_fire_stacks(0.2 + bloodsucker_level / 10)
			owner.ignite_mob()
	// they'll take around 45 damage total during Sol at rank 1, to 150 damage total at rank 8 (not counting any damage from being set on fire)
	owner.take_overall_damage(burn = (0.5 + (bloodsucker_level / 4)) * seconds_between_ticks)
	owner.add_mood_event("vampsleep", /datum/mood_event/daylight)

/datum/status_effect/bloodsucker_sol/proc/on_sol_end()
	SIGNAL_HANDLER
	if(!QDELING(src))
		qdel(src)

/datum/status_effect/bloodsucker_sol/proc/on_owner_moved()
	SIGNAL_HANDLER
	if(istype(owner.loc, /obj/structure/closet/crate/coffin))
		qdel(src)
	else
		update_in_shade()

/datum/status_effect/bloodsucker_sol/proc/update_in_shade()
	SIGNAL_HANDLER
	var/in_shade = HAS_TRAIT(owner, TRAIT_SHADED) || isstructure(owner.loc)
	if(protected != in_shade)
		protected = in_shade
		linked_alert?.update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/alert/status_effect/bloodsucker_sol
	name = "Solar Flares"
	desc = "Solar flares bombard the station!\nSleep in a coffin, hide in a locker, or shade yourself with an umbrella to avoid the effects of the solar flare!"
	icon = 'monkestation/icons/bloodsuckers/actions_bloodsucker.dmi'
	base_icon_state = "sol_alert"
	icon_state = "sol_alert"

/atom/movable/screen/alert/status_effect/bloodsucker_sol/update_icon_state()
	. = ..()
	var/shaded = astype(attached_effect, /datum/status_effect/bloodsucker_sol)?.protected
	icon_state = "[base_icon_state][shaded ? "_shaded" : ""]"

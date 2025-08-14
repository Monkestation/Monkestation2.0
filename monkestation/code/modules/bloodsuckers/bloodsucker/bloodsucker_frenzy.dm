/**
 * # Status effect
 *
 * This is the status effect given to Bloodsuckers in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a Frenzy! You are entirely Feral and, depending on your Clan, fighting for your life!"
	icon = 'monkestation/icons/bloodsuckers/actions_bloodsucker.dmi'
	icon_state = "power_recover"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/frenzy
	/// The stored Bloodsucker antag datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	/// Traits applied during Frenzy.
	var/static/list/frenzy_traits = list(
		TRAIT_BATON_RESISTANCE,
		TRAIT_DEAF,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_MUTE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_STRONG_GRABBER,
	)

/datum/status_effect/frenzy/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] inhumane and feral!")

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	if(QDELETED(bloodsuckerdatum) || !COOLDOWN_FINISHED(bloodsuckerdatum, bloodsucker_frenzy_cooldown))
		return FALSE

	// Disable ALL Powers and notify their entry
	bloodsuckerdatum.DisableAllPowers(forced = TRUE)
	to_chat(owner, span_userdanger("Blood! You need Blood, now! You enter a total Frenzy!"))
	to_chat(owner, span_announce("* Bloodsucker Tip: While in Frenzy, you instantly Aggresively grab, have stun resistance, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	owner.balloon_alert(owner, "you enter a frenzy!")
	SEND_SIGNAL(bloodsuckerdatum, COMSIG_BLOODSUCKER_ENTERS_FRENZY)

	// Give the other Frenzy effects
	owner.add_traits(frenzy_traits, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_frenzy)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	user.uncuff()
	bloodsuckerdatum.frenzied = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	if(bloodsuckerdatum?.frenzied)
		owner.balloon_alert(owner, "you come back to your senses.")
		owner.remove_traits(frenzy_traits, TRAIT_STATUS_EFFECT(id))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/bloodsucker_frenzy)
		owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)

		SEND_SIGNAL(bloodsuckerdatum, COMSIG_BLOODSUCKER_EXITS_FRENZY)
		bloodsuckerdatum.frenzied = FALSE
		COOLDOWN_START(bloodsuckerdatum, bloodsucker_frenzy_cooldown, 30 SECONDS)
	return ..()

/datum/status_effect/frenzy/tick()
	if(!bloodsuckerdatum?.frenzied || bloodsuckerdatum.bloodsucker_blood_volume >= FRENZY_THRESHOLD_EXIT)
		qdel(src)
		return
	owner.take_overall_damage(burn = 1.5 + (bloodsuckerdatum.humanity_lost / 10))

/datum/movespeed_modifier/bloodsucker_frenzy
	multiplicative_slowdown = -0.4

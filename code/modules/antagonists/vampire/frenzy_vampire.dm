/**
 * # Status effect
 *
 * This is the status effect given to Vampires in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */
/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a Frenzy! You are entirely Feral and, depending on your Clan, fighting for your life!"
	icon = 'icons/vampires/actions_vampire.dmi'
	icon_state = "frenzy_alert"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/frenzy

	/// The stored vampire antag datum
	var/datum/antagonist/vampire/vampiredatum

	/// Traits given by frenzy.
	var/static/list/frenzy_traits = list(
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_STRONG_GRABBER,
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
	)

/datum/status_effect/frenzy/Destroy()
	. = ..()
	vampiredatum = null

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/carbon_owner = owner
	if(!iscarbon(carbon_owner))
		return FALSE
	vampiredatum = IS_VAMPIRE(carbon_owner)

	ASSERT(!isnull(vampiredatum), "Frenzy status effect applied to a non-vampire!")

	if(vampiredatum.current_vitae >= FRENZY_THRESHOLD_EXIT)
		return FALSE

	// Basic stuff
	carbon_owner.add_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	carbon_owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	carbon_owner.uncuff()
	carbon_owner.pulledby?.stop_pulling()
	carbon_owner.stamina?.revitalize(forced = TRUE)
	carbon_owner.SetAllImmobility(0)
	carbon_owner.set_resting(FALSE, silent = TRUE, instant = TRUE)

	// Alert them
	vampiredatum.disable_all_powers(forced = TRUE)
	vampiredatum.adjust_humanity(-2)
	to_chat(carbon_owner, span_userdanger("<font size='10'>BLOOD! YOU NEED BLOOD NOW!</font>"))
	to_chat(carbon_owner, span_announce("* Vampire Tip: While in Frenzy, you instantly aggressively grab, have stun immunity, and cannot use any powers outside of Feed and Trespass (If you have it)."))
	carbon_owner.balloon_alert(carbon_owner, "you enter a frenzy!")

	// Stamina modifier
	if (ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		human_owner.physiology?.stamina_mod *= 0.4

	// Traits
	carbon_owner.add_traits(frenzy_traits, TRAIT_FRENZY)

	return TRUE

/datum/status_effect/frenzy/on_remove()
	var/mob/living/carbon/carbon_owner = owner
	if(!iscarbon(carbon_owner))
		return

	COOLDOWN_START(vampiredatum, frenzy_cooldown, 30 SECONDS)

	// Basic stuff
	carbon_owner.remove_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	carbon_owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)

	// Alert them
	carbon_owner.balloon_alert(carbon_owner, "you come back to your senses.")

	// Stamina modifier
	if (ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		human_owner.physiology?.stamina_mod /= 0.4

	// Traits
	carbon_owner.remove_traits(frenzy_traits, TRAIT_FRENZY)

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/carbon_owner = owner
	if(vampiredatum.current_vitae >= FRENZY_THRESHOLD_EXIT)
		qdel(src)
		return
	carbon_owner.adjustFireLoss(0.75)
	carbon_owner.set_jitter_if_lower(10 SECONDS)

/datum/status_effect/frenzy/get_examine_text()
	return span_danger("[owner.p_They()] seem[owner.p_s()]... inhumane, and feral!")

/datum/movespeed_modifier/frenzy_speed
	blacklisted_movetypes = FLYING | FLOATING
	multiplicative_slowdown = -0.1 // Might seem very low but at this point we are already slow as balls from hunger

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

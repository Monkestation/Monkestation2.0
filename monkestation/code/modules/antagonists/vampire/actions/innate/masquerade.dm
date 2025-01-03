/datum/action/cooldown/vampire/masquerade
	name = "Masquerade"
	desc = "Hide your true nature from the prying eyes of the mortals. Drains lifeforce and disables most of your abilities while active. Can be toggled off while unconscious."
	button_icon_state = "power_human"
	toggleable = TRUE // constant_life_cost is handled in set_masquerade
	works_in_masquerade = TRUE
	has_custom_life_cost = TRUE

/datum/action/cooldown/vampire/masquerade/New(Target)
	. = ..()
	check_flags = vampire.masquerade_enabled ? NONE : AB_CHECK_CONSCIOUS // allow toggling it off even while unconscious or dead, but not on

/datum/action/cooldown/vampire/masquerade/Grant(mob/granted_to)
	. = ..()
	RegisterSignals(granted_to, list(SIGNAL_ADDTRAIT(TRAIT_VAMPIRE_FRENZY), SIGNAL_REMOVETRAIT(TRAIT_VAMPIRE_FRENZY), SIGNAL_ADDTRAIT(TRAIT_NO_EXTINGUISH), SIGNAL_REMOVETRAIT(TRAIT_NO_EXTINGUISH)), PROC_REF(update_button))

/datum/action/cooldown/vampire/masquerade/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(SIGNAL_ADDTRAIT(TRAIT_VAMPIRE_FRENZY), SIGNAL_REMOVETRAIT(TRAIT_VAMPIRE_FRENZY), SIGNAL_ADDTRAIT(TRAIT_NO_EXTINGUISH), SIGNAL_REMOVETRAIT(TRAIT_NO_EXTINGUISH)))

/datum/action/cooldown/vampire/masquerade/can_toggle_on(feedback)
	if(HAS_TRAIT_FROM(owner, TRAIT_NO_EXTINGUISH, VAMPIRE_TRAIT)) // cheaper than is_in_starlight
		if(feedback)
			owner.balloon_alert(owner, "in starlight!")
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_VAMPIRE_FRENZY))
		if(feedback)
			owner.balloon_alert(owner, "too bloodlusted!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/masquerade/on_toggle_on()
	vampire.set_masquerade(TRUE)

	owner.visible_message(
		message = span_danger("[owner]'s appearance suddenly morphs to that of a normal person. Was what you saw earlier just an illusion?"),
		self_message = span_notice("You hide your true nature, skin turning vibrant and eyes a natural shade. You could easily pass for a mortal now.")
	)

/datum/action/cooldown/vampire/masquerade/on_toggle_off()
	vampire.set_masquerade(FALSE)

	owner.visible_message(
		message = span_danger("[owner]'s skin suddenly turns a pale grey, [owner.p_their()] eyes begin to glow and a set of ferocious fangs extends from [owner.p_their()] mouth!"),
		self_message = span_notice("You return to your icy pallor, silently hoping to never have to fool another mortal again. Alas, such is the life of our kin.")
	)

/datum/action/cooldown/vampire/masquerade/is_active()
	return vampire.masquerade_enabled

/datum/action/cooldown/vampire/masquerade/on_masquerade(datum/source, enabled)
	check_flags = enabled ? NONE : AB_CHECK_CONSCIOUS // allow toggling it off even while unconscious or dead, but not on
	return ..()

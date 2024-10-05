/datum/action/cooldown/vampire/frenzy
	name = "Frenzy"
	desc = "Enter a state of total bloodlust. Rapidly drains lifeforce while active."
	button_icon_state = "power_frenzy"
	cooldown_time = 2 MINUTES
	toggleable = TRUE
	constant_life_cost = LIFEFORCE_PER_HUMAN / 60 // the duration is 30 seconds so this should drain roughly 50 lifeforce

	var/mutable_appearance/overlay

/datum/action/cooldown/vampire/frenzy/on_toggle_on()
	vampire.set_stat_multiplier(VAMPIRE_STAT_BRUTALITY, REF(src), 1.5)
	vampire.set_stat_multiplier(VAMPIRE_STAT_PURSUIT, REF(src), 1.5)
	ADD_TRAIT(owner, TRAIT_VAMPIRE_FRENZY, REF(src))

	overlay = mutable_appearance('monkestation/icons/vampires/overlays_vampire.dmi', "frenzy", offset_spokesman = owner)
	overlay.blend_mode = BLEND_INSET_OVERLAY
	owner.add_overlay(overlay)

	owner.add_filter(REF(src), 1, outline_filter(1, "#ff3333"))

	RegisterSignal(vampire, COMSIG_VAMPIRE_END_FRENZY, PROC_REF(toggle_off))

	user.apply_status_effect(/datum/status_effect/vampire/frenzy, vampire)

/datum/action/cooldown/vampire/frenzy/on_toggle_off()
	vampire.clear_stat_multiplier(VAMPIRE_STAT_BRUTALITY, REF(src))
	vampire.clear_stat_multiplier(VAMPIRE_STAT_PURSUIT, REF(src))
	REMOVE_TRAIT(owner, TRAIT_VAMPIRE_FRENZY, REF(src))

	owner.cut_overlay(overlay)
	QDEL_NULL(overlay)

	owner.remove_filter(REF(src))

	UnregisterSignal(vampire, COMSIG_VAMPIRE_END_FRENZY)

	user.remove_status_effect(/datum/status_effect/vampire/frenzy)

/datum/action/cooldown/vampire/frenzy/can_toggle_off(feedback)
	if(owner.stat == DEAD)
		return TRUE
	if(feedback)
		owner.balloon_alert(owner, "too bloodlusted!")
	return FALSE

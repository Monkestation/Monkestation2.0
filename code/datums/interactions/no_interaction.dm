/// Internal interaction mode to force upon mobs that should not have an interaction mode, such as AIs
/datum/interaction_mode/no_interaction
	var/default_istate = NONE /// Default istate
	var/handleModifierIstates = FALSE /// Should we still handle modifier istates? (ISTATE_SECONDARY and ISTATE_CONTROL)

/datum/interaction_mode/no_interaction/update_istate(mob/M, modifiers)
	M.istate = default_istate
	if(handleModifierIstates)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			M.istate |= ISTATE_SECONDARY
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			M.istate |= ISTATE_CONTROL

/datum/interaction_mode/no_interaction/nopassthrough
	default_istate = ISTATE_HARM | ISTATE_BLOCKING

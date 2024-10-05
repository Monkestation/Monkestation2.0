/datum/vampire_ability/efficient
	name = "Efficient"
	desc = "You do things a lot faster. \
		Scales with Brutality."
	stat_reqs = list(VAMPIRE_STAT_BRUTALITY = 2)

/datum/vampire_ability/efficient/on_grant_mob()
	RegisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_modifier()

/datum/vampire_ability/efficient/on_remove_mob()
	UnregisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD)
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/vampire_brutality)

/datum/vampire_ability/efficient/proc/on_stat_changed(datum/source, stat, old_value, new_value)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_BRUTALITY)
		return
	update_modifier(new_value)

/datum/vampire_ability/efficient/proc/update_modifier(brutality = owner.get_stat_modified(VAMPIRE_STAT_BRUTALITY))
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/vampire_brutality, multiplicative_slowdown = brutality / VAMPIRE_SP_MAXIMUM * -0.4) // mult slowdown of -0.4 at max and -0.6 with frenzy

/datum/actionspeed_modifier/vampire_brutality
	variable = TRUE

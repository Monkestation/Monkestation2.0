/datum/vampire_ability/bonebreaker
	name = "Bonebreaker"
	desc = "Your punches deal more damage. \
		Scales with Brutality."
	stat_reqs = list(VAMPIRE_STAT_BRUTALITY = 1)

	var/damage_mod

/datum/vampire_ability/bonebreaker/on_grant_mob()
	RegisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_mod()

/datum/vampire_ability/bonebreaker/on_remove_mob()
	UnregisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	clear_mod()

/datum/vampire_ability/bonebreaker/proc/on_stat_changed(datum/source, stat, old_value, new_value)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_BRUTALITY)
		return
	update_mod(new_value)

/datum/vampire_ability/bonebreaker/proc/update_mod(brutality = owner.get_stat_modified(VAMPIRE_STAT_BRUTALITY))
	clear_mod()

	damage_mod = 1 + (brutality / VAMPIRE_SP_MAXIMUM) * 2 // 3x punch damage at max (even more with frenzy)
	user.physiology.unarmed_damage_mod *= damage_mod

/datum/vampire_ability/bonebreaker/proc/clear_mod()
	if(isnull(damage_mod))
		return

	user.physiology.unarmed_damage_mod /= damage_mod
	damage_mod = null

/datum/vampire_ability/resilient
	name = "Resilient"
	desc = "You are resistant to incoming damage as well as stuns. \
		Additionally, dying from thirst takes a lot longer. \
		Scales with Tenacity."
	stat_reqs = list(VAMPIRE_STAT_TENACITY = 1)

	var/damage_mod

/datum/vampire_ability/resilient/on_grant_mob()
	RegisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_mod()

/datum/vampire_ability/resilient/on_remove_mob()
	UnregisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	clear_mod()

/datum/vampire_ability/resilient/proc/on_stat_changed(datum/source, stat, old_value, new_value)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_TENACITY)
		return
	update_mod(new_value)

/datum/vampire_ability/resilient/proc/update_mod(tenacity = owner.get_stat_modified(VAMPIRE_STAT_TENACITY))
	clear_mod()

	damage_mod = 1 - (tenacity / VAMPIRE_SP_MAXIMUM) * 0.4 // 0.6x incoming damage at max
	user.physiology.brute_mod *= damage_mod
	user.physiology.burn_mod *= damage_mod
	user.physiology.stun_mod *= damage_mod
	user.physiology.stamina_mod *= damage_mod // This means by default you take 3-4 baton hits to even get downed, on top of getting up faster due to stun resistance. Recovery path still gets up faster.

/datum/vampire_ability/resilient/proc/clear_mod()
	if(isnull(damage_mod))
		return

	user.physiology.brute_mod /= damage_mod
	user.physiology.burn_mod /= damage_mod
	user.physiology.stun_mod /= damage_mod
	user.physiology.stamina_mod /= damage_mod
	damage_mod = null

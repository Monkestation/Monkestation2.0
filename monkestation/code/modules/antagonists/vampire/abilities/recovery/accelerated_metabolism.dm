/datum/vampire_ability/accelerated_metabolism
	name = "Accelerated Metabolism"
	desc = "Your bodily functions are accelerated, making you recover from exhaustion faster. This is passive and does not depend on Recuperation."
	stat_reqs = list(VAMPIRE_STAT_RECOVERY = 1)

	var/regen_increase

/datum/vampire_ability/accelerated_metabolism/on_grant_mob()
	RegisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_mod()

/datum/vampire_ability/accelerated_metabolism/on_remove_mob()
	UnregisterSignal(owner, COMSIG_VAMPIRE_STAT_CHANGED_MOD)
	user.stamina.regen_rate -= regen_increase
	regen_increase = null

/datum/vampire_ability/accelerated_metabolism/proc/on_stat_changed(datum/source, stat, old_amount, new_amount)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_RECOVERY)
		return
	update_mod(new_amount)

/datum/vampire_ability/accelerated_metabolism/proc/update_mod(recovery = owner.get_stat_modified(VAMPIRE_STAT_RECOVERY))
	if(!isnull(regen_increase))
		user.stamina.regen_rate -= regen_increase

	regen_increase = initial(user.stamina.regen_rate) * (recovery / VAMPIRE_SP_MAXIMUM) * 2 // 3x stamina regen at max. (Stronger than Resilient's stamina damage resistance numerically, but not as useful against batons.)
	user.stamina.regen_rate += regen_increase

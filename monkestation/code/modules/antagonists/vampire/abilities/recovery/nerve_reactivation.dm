/datum/vampire_ability/nerve_reactivation
	name = "Nerve Reactivation"
	desc = "Your nerves send reactivation signals to surrounding tissues when incapacitated. This is passive and does not depend on Recuperation."
	stat_reqs = list(VAMPIRE_STAT_RECOVERY = 2)

/datum/vampire_ability/nerve_reactivation/on_grant_mob()
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/vampire_ability/nerve_reactivation/on_remove_mob()
	UnregisterSignal(user, COMSIG_LIVING_LIFE)

/datum/vampire_ability/nerve_reactivation/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	user.AdjustAllImmobility(-seconds_per_tick * (owner.get_stat_modified(VAMPIRE_STAT_RECOVERY) / VAMPIRE_SP_MAXIMUM) * 2) // 3x stun regen at max. (Stronger than Resilient's stun resistance numerically, but not as useful against batons.)

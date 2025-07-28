/datum/component/regenerator/RegisterWithParent()
	. = ..()
	RegisterSignals(parent, COMSIG_LIVING_ADJUST_ALL_DAMAGE_TYPES, PROC_REF(on_adjust_damage))

/datum/component/regenerator/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_ALL_DAMAGE_TYPES)

/datum/component/regenerator/proc/on_adjust_damage(datum/source, damagetype, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		on_take_damage(source, damage, damagetype)

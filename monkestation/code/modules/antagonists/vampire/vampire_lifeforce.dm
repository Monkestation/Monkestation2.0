/datum/antagonist/vampire/proc/update_lifeforce_changes()
	lifeforce_per_second = 0
	for(var/source as anything in lifeforce_changes)
		var/change = lifeforce_changes[source]
		lifeforce_per_second += change

/datum/antagonist/vampire/proc/set_lifeforce_change(source, amount)
	lifeforce_changes[source] = amount
	update_lifeforce_changes()

/datum/antagonist/vampire/proc/clear_lifeforce_change(source)
	lifeforce_changes -= source
	update_lifeforce_changes()

/datum/antagonist/vampire/proc/set_lifeforce(amount)
	var/old_amount = lifeforce

	lifeforce = max(0, amount)

	if(old_amount == lifeforce)
		return

	SEND_SIGNAL(src, COMSIG_VAMPIRE_LIFEFORCE_CHANGED, old_amount, lifeforce)

	update_hud()

	if(lifeforce > LIFEFORCE_MAXIMUM)
		set_lifeforce_change(LIFEFORCE_CHANGE_OVERFLOW, -1 - (lifeforce - LIFEFORCE_MAXIMUM) * 0.05) // lose 1 per second initially and an additional 1 per 20 excess
	else if(old_amount > LIFEFORCE_MAXIMUM)
		clear_lifeforce_change(LIFEFORCE_CHANGE_OVERFLOW)

	if(lifeforce <= 0)
		owner.current.apply_status_effect(/datum/status_effect/vampire/thirst, src) // it should be impossible for this to happen multiple times, clearly you should trust me

/datum/antagonist/vampire/proc/adjust_lifeforce(amount)
	set_lifeforce(lifeforce + amount)

/datum/antagonist/vampire/proc/set_stat(stat, amount)
	var/old_amount = get_stat(stat)

	if(amount < old_amount)
		CRASH("Attempted to lower vampire stat [stat]. This is undefined behaviour and will lead to issues.")

	var/new_amount = clamp(amount, 0, VAMPIRE_SP_MAXIMUM)
	if(new_amount == old_amount)
		return

	var/old_modified_amount = get_stat_modified(stat)

	var/delta = new_amount - old_amount
	stats[stat] = new_amount
	spent_stat_points += delta
	available_stat_points -= delta

	var/new_modified_amount = get_stat_modified(stat)

	check_new_unlocks_by_stat(stat)

	SEND_SIGNAL(src, COMSIG_VAMPIRE_STAT_CHANGED, stat, old_amount, new_amount)

	if(old_modified_amount == new_modified_amount)
		return

	SEND_SIGNAL(src, COMSIG_VAMPIRE_STAT_CHANGED_MOD, stat, old_modified_amount, new_modified_amount)

/datum/antagonist/vampire/proc/adjust_stat(stat, amount)
	set_stat(stat, stats[stat] + amount)

/// Gets the value of a stat. Ignores stat_mods, use get_stat_modified() for scaling.
/datum/antagonist/vampire/proc/get_stat(stat) as num
	var/amount = stats[stat]
	return amount ? amount : 0

/datum/antagonist/vampire/proc/set_stat_points(amount)
	if(amount == stat_points)
		return
	if(amount < stat_points)
		CRASH("Attempted to lower vampire stat points. This is undefined behaviour and will lead to issues.")
	available_stat_points += amount - stat_points
	stat_points = amount

/datum/antagonist/vampire/proc/adjust_stat_points(amount)
	set_stat_points(stat_points + amount)

/// Same as get_stat() but it's affected by modifiers. Can be a decimal. Use for scaling.
/datum/antagonist/vampire/proc/get_stat_modified(stat) as num
	var/value = get_stat(stat)
	var/datum/modifier/mod = stat_mods[stat]
	if(mod)
		value *= mod.get_value()
	return value

/datum/antagonist/vampire/proc/set_stat_multiplier(stat, source, multiplier)
	var/datum/modifier/modifier = stat_mods[stat]

	if(!modifier)
		modifier = new // a single undestroyed datum costs fuckall and modifiers exclusively use lazylists anyway, so this is fine
		stat_mods[stat] = modifier

	var/old_modified_amount = get_stat_modified(stat)

	modifier.set_multiplicative(source, multiplier)

	var/new_modified_amount = get_stat_modified(stat)

	if(old_modified_amount == new_modified_amount)
		return

	SEND_SIGNAL(src, COMSIG_VAMPIRE_STAT_CHANGED_MOD, stat, old_modified_amount, new_modified_amount)

/datum/antagonist/vampire/proc/clear_stat_multiplier(stat, source)
	var/datum/modifier/modifier = stat_mods[stat]

	if(!modifier)
		return

	var/old_modified_amount = get_stat_modified(stat)

	modifier.clear_multiplicative(source)

	var/new_modified_amount = get_stat_modified(stat)

	if(old_modified_amount == new_modified_amount)
		return

	SEND_SIGNAL(src, COMSIG_VAMPIRE_STAT_CHANGED_MOD, stat, old_modified_amount, new_modified_amount)

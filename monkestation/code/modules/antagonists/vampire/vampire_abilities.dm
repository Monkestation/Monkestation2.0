
/// Checks if the vampire has any new abilities to unlock.
/datum/antagonist/vampire/proc/check_new_unlocks()
	for(var/ability as anything in GLOB.vampire_all_abilities)
		check_ability_reqs(ability)

/datum/antagonist/vampire/proc/check_new_unlocks_by_stat(stat_name)
	var/abilities = GLOB.vampire_abilities_stat[stat_name]
	if(!abilities)
		return
	for(var/ability as anything in abilities)
		check_ability_reqs(ability)

/datum/antagonist/vampire/proc/check_new_unlocks_by_rank(rank)
	var/abilities = GLOB.vampire_abilities_rank[rank]
	if(!abilities)
		return
	for(var/ability as anything in abilities)
		check_ability_reqs(ability)

/// Checks the requirements for the given type of ability and grants it to the vampire if they're met.
/datum/antagonist/vampire/proc/check_ability_reqs(datum/vampire_ability/ability_type)
	if(current_abilities[ability_type])
		return

	if(!can_unlock_ability(ability_type))
		return

	var/datum/vampire_ability/ability = new ability_type
	current_abilities[ability_type] = ability
	ability.grant(src)

/// Removes all abilities from the vampire.
/datum/antagonist/vampire/proc/clear_abilities()
	for(var/ability_type as anything in current_abilities)
		var/datum/vampire_ability/ability = current_abilities[ability_type]
		ability.remove()
	current_abilities.Cut()

/// Returns whether the given vampire meets the requirements to get this ability.
/datum/antagonist/vampire/proc/can_unlock_ability(datum/vampire_ability/ability_type)
	if(vampire_rank < initial(ability_type.min_rank))
		return FALSE

	var/clan_req = initial(ability_type.clan_req)
	if(clan_req && clan != clan_req)
		return FALSE

	var/list/stat_reqs = GLOB.vampire_abilities_reqs[ability_type]
	for(var/stat as anything in stat_reqs)
		if(get_stat(stat) < stat_reqs[stat])
			return FALSE

	return TRUE

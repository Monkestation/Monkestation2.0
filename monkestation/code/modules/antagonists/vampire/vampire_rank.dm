/datum/antagonist/vampire/proc/set_rank(new_rank, force_update = FALSE)
	if(new_rank < vampire_rank)
		CRASH("Attempted to lower vampire rank. This is undefined behaviour and will lead to issues.")

	var/old_rank = vampire_rank
	new_rank = clamp(new_rank, 0, VAMPIRE_RANK_MAX)

	if(new_rank == old_rank && !force_update)
		return

	if(old_rank == 0) // Thrall -> Vampire
		name = "\improper Vampire"
		roundend_category = "Vampire"
		UnregisterSignal(owner, COMSIG_LIVING_DEATH) // unregisters de_thrall so that after becoming a full vampire you cannot be reverted
		regen_rate_modifier.clear_multiplicative(REF(src)) // removes thrall debuff from regen rate

	vampire_rank = new_rank

	update_hud()

	var/new_stat_points = VAMPIRE_SP_PER_RANK * new_rank
	if(istype(clan, /datum/vampire_clan/caitiff))
		new_stat_points += VAMPIRE_SP_CAITIFF_BONUS * new_rank
	set_stat_points(new_stat_points)

	check_new_unlocks_by_rank()

	SEND_SIGNAL(src, COMSIG_VAMPIRE_RANK_CHANGED, old_rank)

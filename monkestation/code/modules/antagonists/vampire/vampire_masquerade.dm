/// Updates the current state of masquerade.
/datum/antagonist/vampire/proc/update_masquerade()
	if(masquerade_enabled)
		owner.current.remove_traits(visible_traits, VAMPIRE_TRAIT)
		owner.current.add_traits(masquerade_traits, VAMPIRE_TRAIT)
		owner.current.RemoveElement(/datum/element/cult_eyes)
		set_lifeforce_change(LIFEFORCE_CHANGE_MASQUERADE, LIFEFORCE_DRAIN_BASE) // doubled drain rate
	else
		owner.current.add_traits(visible_traits, VAMPIRE_TRAIT)
		owner.current.remove_traits(masquerade_traits, VAMPIRE_TRAIT)
		owner.current.AddElement(/datum/element/cult_eyes, initial_delay = 0 SECONDS)
		clear_lifeforce_change(LIFEFORCE_CHANGE_MASQUERADE)

	SEND_SIGNAL(src, COMSIG_VAMPIRE_MASQUERADE, masquerade_enabled)

/// Enables or disables masquerade.
/datum/antagonist/vampire/proc/set_masquerade(enabled)
	if(enabled == masquerade_enabled)
		return
	masquerade_enabled = enabled
	update_masquerade()

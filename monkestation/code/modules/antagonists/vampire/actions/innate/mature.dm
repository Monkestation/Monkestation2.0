/datum/action/cooldown/vampire/mature
	name = "Mature"
	desc = "Grow closer to your ancient lineage through sacrificing your lifeforce."
	button_icon_state = "power_mature"
	cooldown_time = 10 SECONDS
	works_in_masquerade = TRUE

/datum/action/cooldown/vampire/mature/New(Target)
	. = ..()
	RegisterSignal(vampire, COMSIG_VAMPIRE_RANK_CHANGED, PROC_REF(update_cost))
	update_cost()

/datum/action/cooldown/vampire/mature/Destroy()
	UnregisterSignal(vampire, COMSIG_VAMPIRE_RANK_CHANGED)
	return ..()

/datum/action/cooldown/vampire/mature/IsAvailable(feedback)
	if(!..())
		return FALSE

	if(vampire.vampire_rank >= VAMPIRE_RANK_MAX)
		if(feedback)
			owner.balloon_alert(owner, "maxed out!")
		return FALSE

	return TRUE

/datum/action/cooldown/vampire/mature/Activate()
	if(vampire.vampire_rank >= VAMPIRE_RANK_MAX)
		to_chat(owner, span_boldnotice("You've done it! You've reached the epitome of vampiric prowess!"))
	else
		to_chat(owner, span_boldnotice("You feel your body quiver as your biology morphs closer to your ancient lineage."))

	. = ..()

	vampire.set_rank(vampire.vampire_rank + 1) // doing this before calling parent fucks up the cost

/datum/action/cooldown/vampire/mature/proc/update_cost()
	SIGNAL_HANDLER
	life_cost = VAMPIRE_RANKUP_COST + VAMPIRE_RANKUP_SCALING * vampire.vampire_rank
	update_button()

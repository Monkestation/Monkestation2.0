/// Instantly turns the target into a thrall with this datum as its master.
/datum/antagonist/vampire/proc/enthrall(mob/living/carbon/human/target)
	var/datum/antagonist/vampire/thrall/thrall = new(src)
	target.mind.add_antag_datum(thrall)
	target.investigate_log("has been enthralled by [key_name(owner.current)].", INVESTIGATE_DEATHS)

/datum/antagonist/vampire/thrall
	name = "\improper Thrall"
	roundend_category = "thralls"
	starting_rank = 0
	masquerade_enabled = FALSE
	lifeforce = LIFEFORCE_THRALL

	/// List of our masters. Use helpers to access this.
	var/list/masters = list()

	/// How far back the master lineage goes. Counts previous masters too.
	var/master_count = 0

/datum/antagonist/vampire/thrall/New(datum/antagonist/vampire/master)
	. = ..()

	add_master(master)

	if(istype(master, /datum/antagonist/vampire/thrall))
		var/datum/antagonist/vampire/thrall/thrall_master = master
		for(var/higher_master as anything in thrall_master.masters)
			add_master(higher_master)

/datum/antagonist/vampire/thrall/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(de_thrall)) //DEVNOTE: Put the unregister on datum loss AND when they upgrade to full vamp
	regen_rate_modifier.set_multiplicative(REF(src), 0.5) // thralls have halved regeneration

/datum/antagonist/vampire/thrall/proc/add_master(datum/antagonist/vampire/master)
	masters[master] = ++master_count
	RegisterSignal(master, COMSIG_QDELETING, PROC_REF(remove_master))

/datum/antagonist/vampire/thrall/proc/remove_master(datum/antagonist/vampire/master)
	SIGNAL_HANDLER
	masters -= master
	UnregisterSignal(master, COMSIG_QDELETING)

/// Returns a master index for the given vampire datum if they're one of your masters and 0 otherwise. Higher indexes have more authority over you.
/datum/antagonist/vampire/thrall/proc/get_master_index(datum/antagonist/vampire/other_vampire)
	var/index = masters[other_vampire]
	return !isnull(index) ? index : 0

/datum/antagonist/vampire/thrall/proc/de_thrall()
	SIGNAL_HANDLER
	if(owner.current.stat == DEAD)
		owner.current.blood_volume = 0
		owner.remove_antag_datum(/datum/antagonist/vampire/thrall)


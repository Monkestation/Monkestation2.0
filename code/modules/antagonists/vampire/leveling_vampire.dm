/**
 * Called every 15 minutes or so. Give our vampire a level to spend.
**/
/datum/antagonist/vampire/proc/give_natural_level()
	if(QDELETED(owner.current) || free_levels_remaining < 1)
		return
	owner.current.balloon_alert(owner.current, "you have grown more ancient!")
	free_levels_remaining--
	INVOKE_ASYNC(src, PROC_REF(rank_up), 1, TRUE)

SUBSYSTEM_DEF(vampire_leveling)
	name = "Vampire Leveling"
	wait = 15 MINUTES
	flags = SS_NO_INIT | SS_KEEP_TIMING
	can_fire = FALSE

/datum/controller/subsystem/vampire_leveling/fire(resumed = FALSE)
	for(var/datum/antagonist/vampire/vampire as anything in GLOB.all_vampires)
		vampire.give_natural_level()

/datum/controller/subsystem/vampire_leveling/proc/check_enable()
	if(length(GLOB.all_vampires))
		can_fire = TRUE
	else
		can_fire = FALSE

PROCESSING_SUBSYSTEM_DEF(challenges)
	name = "Challenges"
	wait = 10 SECONDS
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

/datum/controller/subsystem/processing/challenges/proc/apply_challenges(datum/persistent_client/owner)
	if(!owner)
		CRASH("Attempted to apply challenges to invalid owner")
	for(var/datum/challenge/listed as anything in owner.active_challenges)
		var/datum/challenge/new_challenge = new listed(owner)
		new_challenge.on_apply(owner)

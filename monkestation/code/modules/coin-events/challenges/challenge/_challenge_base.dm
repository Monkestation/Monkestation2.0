/datum/challenge
	///the challenge name
	var/challenge_name = "God's Weakest Challenge"
	///the challenge payout
	var/challenge_payout = 100
	///our host
	var/datum/persistent_client/host
	///have we failed if we are a fail action
	var/failed = FALSE
	///the difficulty of the channgle
	var/difficulty = "Easy"
	///do we need to process?
	var/processes = FALSE
	///the trait we apply if any
	var/applied_trait

/datum/challenge/New(datum/persistent_client/host)
	. = ..()
	if(!host)
		return
	src.host = host
	RegisterSignal(host.mob, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

/datum/challenge/Destroy(force)
	host = null
	return ..()

///we just use the client to try and apply this as its easier to track mobs
/datum/challenge/proc/on_apply()
	SHOULD_CALL_PARENT(TRUE)
	LAZYADD(host.applied_challenges, src)
	if(!applied_trait)
		return
	ADD_TRAIT(host.mob, applied_trait, CHALLENGE_TRAIT)

///this fires every 10 seconds
/datum/challenge/proc/on_process()
	return

///this fires when the mob dies
/datum/challenge/proc/on_death()
	return

///this fires when a mob is revived
/datum/challenge/proc/on_revive()
	return

/datum/challenge/proc/on_transfer(datum/mind/source, mob/previous_body)
	SIGNAL_HANDLER
	if(applied_trait)
		REMOVE_TRAIT(previous_body, applied_trait, CHALLENGE_TRAIT)
		ADD_TRAIT(source.current, applied_trait, CHALLENGE_TRAIT)

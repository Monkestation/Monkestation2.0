// Oozeling vampires have some unique behavior, so I'm just gonna stick it all in this one file.

/// Handles setting up self-revival when an oozeling vampire dies.
/datum/antagonist/vampire/proc/on_oozeling_core_ejected(datum/source, obj/item/organ/internal/brain/slime/core)
	SIGNAL_HANDLER
	if(QDELETED(core))
		return
	if(current_vitae < OOZELING_MIN_REVIVE_BLOOD_THRESHOLD)
		to_chat(core.brainmob, span_narsiesmall("You do not have enough vitae to recollect yourself on your own!"), type = MESSAGE_TYPE_WARNING)
		return
	ADD_TRAIT(core, TRAIT_NO_ORGAN_DECAY, TRAIT_VAMPIRE)
	AdjustBloodVolume(-OOZELING_MIN_REVIVE_BLOOD_THRESHOLD * 0.5)
	to_chat(core.brainmob, span_narsiesmall("You begin recollecting yourself. You will rise again soon, if your core remains undisturbed."), type = MESSAGE_TYPE_INFO)
	new /datum/vampire_oozeling_reviver(src, core)

/// Heals an oozeling vampire's organs when they revive.
/datum/antagonist/vampire/proc/on_oozeling_revive(datum/source, mob/living/carbon/human/new_body, obj/item/organ/internal/brain/slime/core)
	SIGNAL_HANDLER
	REMOVE_TRAIT(core, TRAIT_NO_ORGAN_DECAY, TRAIT_VAMPIRE)
	heal_vampire_organs()

/datum/antagonist/vampire/proc/oozeling_self_revive(obj/item/organ/internal/brain/slime/core)
	if(QDELETED(core))
		return
	var/mob/living/carbon/human/new_body = core.rebuild_body(nugget = FALSE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	to_chat(new_body, span_cultlarge("You recollect yourself, your vitae reforming your body from your core!"), type = MESSAGE_TYPE_INFO)

/// Stupid datum used for, to avoid a bunch of oozeling-specific vars on the vampire datum
/datum/vampire_oozeling_reviver
	/// The parent vampire antag datum.
	var/datum/antagonist/vampire/vampire
	/// The oozeling core we're reviving.
	var/obj/item/organ/internal/brain/slime/core
	/// Progress ticker used for reviving.
	var/oozeling_revival_progress = OOZELING_VAMPIRE_REVIVE_TIME
	/// The last world.time where we processed.
	var/last_process
	/// Cooldown for sending a chat message to the oozeling player how long until they revive.
	COOLDOWN_DECLARE(reminder_cooldown)

/datum/vampire_oozeling_reviver/New(datum/antagonist/vampire/vampire, obj/item/organ/internal/brain/slime/core)
	src.vampire = vampire
	src.core = core
	src.last_process = world.time
	RegisterSignal(core, COMSIG_QDELETING, PROC_REF(delete_self))
	RegisterSignal(vampire.owner, COMSIG_OOZELING_REVIVED, PROC_REF(delete_self))
	START_PROCESSING(SSfastprocess, src)

/datum/vampire_oozeling_reviver/Destroy(force)
	UnregisterSignal(core, COMSIG_QDELETING)
	UnregisterSignal(vampire.owner, COMSIG_OOZELING_REVIVED)
	STOP_PROCESSING(SSfastprocess, src)
	vampire = null
	core = null
	return ..()

/datum/vampire_oozeling_reviver/proc/delete_self()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/datum/vampire_oozeling_reviver/proc/progress_multiplier()
	. = 1
	if(istype(core.loc, /obj/structure/closet/crate/coffin))
		return OOZELING_VAMPIRE_REVIVE_COFFIN_MULTIPLIER
	else
		var/mob/living/holder = get(core, /mob/living)
		if(!QDELETED(holder))
			if(HAS_MIND_TRAIT(holder, TRAIT_VAMPIRE_ALIGNED))
				return OOZELING_VAMPIRE_REVIVE_ALLY_MULTIPLIER
			else
				return OOZELING_VAMPIRE_REVIVE_HELD_MULTIPLIER

/datum/vampire_oozeling_reviver/process(seconds_per_tick)
	if(QDELETED(core) || !core.core_ejected)
		delete_self()
		return
	oozeling_revival_progress -= (world.time - last_process) * progress_multiplier()
	last_process = world.time
	if(oozeling_revival_progress <= 0)
		vampire.oozeling_self_revive(core)
		delete_self()
	else if(COOLDOWN_FINISHED(src, reminder_cooldown))
		var/progress = round((1 - (oozeling_revival_progress / OOZELING_VAMPIRE_REVIVE_TIME)) * 100, 1)
		to_chat(core.brainmob, span_cultlarge("Your vitae coagulates... You are approximately [progress]% reformed."), type = MESSAGE_TYPE_INFO)
		COOLDOWN_START(src, reminder_cooldown, 15 SECONDS)

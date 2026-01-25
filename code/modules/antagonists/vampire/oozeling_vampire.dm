// Oozeling vampires have some unique behavior, so I'm just gonna stick it all in this one file.

/// Returns the world.time in which a vampire-oozeling should self-revive.
/// If left alone, they revive in around 1 minute.
/// If held by a non-"ally", they revive in 3 minutes.
/// If put into a coffin, they revive in just under 25 seconds.
/datum/antagonist/vampire/proc/get_oozeling_revive_time()
	. = 0
	if(!isbrain(owner.current) || !oozeling_revive_start_time)
		return
	var/obj/item/organ/internal/brain/slime/core = owner.current.loc
	if(!is_oozeling_core(core) || QDELING(core))
		return
	var/multiplier = 1
	if(istype(core.loc, /obj/structure/closet/crate/coffin))
		multiplier = OOZELING_VAMPIRE_REVIVE_COFFIN_MULTIPLIER
	else
		var/mob/living/holder = get(core, /mob/living)
		if(!QDELETED(holder) && !HAS_MIND_TRAIT(holder, TRAIT_VAMPIRE_ALIGNED))
			multiplier = OOZELING_VAMPIRE_REVIVE_HELD_MULTIPLIER
	return oozeling_revive_start_time + (OOZELING_VAMPIRE_REVIVE_TIME / multiplier)

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
	oozeling_revive_start_time = world.time
	to_chat(core.brainmob, span_narsiesmall("You begin recollecting yourself. You will rise again in [DisplayTimeText(get_oozeling_revive_time() - world.time, 1)], if your core remains undisturbed."), type = MESSAGE_TYPE_INFO)
	COOLDOWN_START(src, oozeling_revive_reminder_cooldown, 15 SECONDS)
	oozeling_revive_check_timer = addtimer(CALLBACK(src, PROC_REF(check_oozeling_revival), core), 1 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_LOOP)

/// Checks to see if we should revive.
/datum/antagonist/vampire/proc/check_oozeling_revival(obj/item/organ/internal/brain/slime/core)
	if(QDELETED(core) || !core.core_ejected)
		deltimer(oozeling_revive_check_timer)
		oozeling_revive_check_timer = null
		oozeling_revive_start_time = 0
		return
	var/revive_at = get_oozeling_revive_time()
	if(world.time >= revive_at)
		oozeling_self_revive(core)
	else if(COOLDOWN_FINISHED(src, oozeling_revive_reminder_cooldown))
		to_chat(core.brainmob, span_cultlarge("Your vitae coagulates... You will rise in [DisplayTimeText(get_oozeling_revive_time() - world.time, 1)]."), type = MESSAGE_TYPE_INFO)
		COOLDOWN_START(src, oozeling_revive_reminder_cooldown, 15 SECONDS)

/// Heals an oozeling vampire's organs when they revive.
/datum/antagonist/vampire/proc/on_oozeling_revive(datum/source, mob/living/carbon/human/new_body, obj/item/organ/internal/brain/slime/core)
	SIGNAL_HANDLER
	REMOVE_TRAIT(core, TRAIT_NO_ORGAN_DECAY, TRAIT_VAMPIRE)
	if(oozeling_revive_check_timer)
		deltimer(oozeling_revive_check_timer)
		oozeling_revive_check_timer = null
	oozeling_revive_start_time = 0
	heal_vampire_organs()

/datum/antagonist/vampire/proc/oozeling_self_revive(obj/item/organ/internal/brain/slime/core)
	if(oozeling_revive_check_timer)
		deltimer(oozeling_revive_check_timer)
		oozeling_revive_check_timer = null
	oozeling_revive_start_time = 0
	if(QDELETED(core))
		return
	var/mob/living/carbon/human/new_body = core.rebuild_body(nugget = FALSE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	to_chat(new_body, span_cultlarge("You recollect yourself, your vitae reforming your body from your core!"), type = MESSAGE_TYPE_INFO)

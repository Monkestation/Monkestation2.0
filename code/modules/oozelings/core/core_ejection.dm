/obj/item/organ/internal/brain/slime/proc/on_stat_change(mob/living/carbon/victim, new_stat, turf/loc_override)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		return

	mind = victim.mind || victim.last_mind
	copy_mind_and_dna(victim)
	addtimer(CALLBACK(src, PROC_REF(core_ejection), victim), 0) // explode them after the current proc chain ends, to avoid weirdness

/obj/item/organ/internal/brain/slime/proc/copy_mind_and_dna(mob/living/carbon/human/slime)
	if(QDELETED(mind))
		mind = brainmob?.mind || slime.mind || slime.last_mind

	if(isnull(slime.dna))
		QDEL_NULL(stored_dna)
	else
		if(QDELETED(stored_dna))
			stored_dna = new
		slime.dna.copy_dna(stored_dna)

	var/datum/language_holder/slime_language_holder = slime.get_language_holder()
	if(slime_language_holder)
		stored_language_holder = new slime_language_holder.type
		stored_language_holder.copy_languages(slime_language_holder)

	if(slime.voice)
		copy_voice_from(slime)

	stored_physique = slime.physique

/// Makes it so that when a slime dies, their core ejects and their body is qdel'd.
/obj/item/organ/internal/brain/slime/proc/core_ejection(mob/living/carbon/human/victim)
	if(core_ejected || !coredeath)
		return

	GLOB.dead_oozeling_cores |= src
	core_ejected = TRUE
	victim.visible_message(span_warning("[victim]'s body completely dissolves, collapsing outwards!"), span_notice("Your body completely dissolves, collapsing outwards!"), span_notice("You hear liquid splattering."))
	var/turf/death_turf = get_turf(victim)
	var/mob/living/basic/mining/legion/legionbody = astype(victim.loc)
	if(legionbody)
		ADD_TRAIT(src, TRAIT_NO_ORGAN_DECAY, REF(legionbody))

	for(var/datum/quirk/quirk in victim.quirks) // Store certain quirks safe to transfer between bodies.
		if(!(quirk.quirk_flags & QUIRK_OOZELING_SAVE))
			continue
		quirk.remove_from_current_holder(quirk_transfer = TRUE)
		stored_quirks |= quirk

	store_item_slots(victim)
	victim.drop_all_held_items()
	process_items(victim) // Start moving items before anything else can touch them.

	if(victim.get_organ_slot(ORGAN_SLOT_BRAIN) == src)
		Remove(victim)
	//Make this check more generalized later. For antags that eat people as they kill. Make sure they drop their
	//contents after death; that is if that is how that item or antag works.
	forceMove(legionbody || death_turf)
	wash(CLEAN_WASH)
	new death_melt_type(death_turf, victim.dir)

	do_steam_effects(death_turf)
	playsound(victim, 'sound/effects/blob/blobattack.ogg', 80, TRUE)

	if(gps_active) // adding the gps signal if they have activated the ability
		AddComponent(/datum/component/gps/no_bsa, "[victim.real_name]'s Core")

	if(brainmob)
		if(stored_language_holder)
			brainmob.get_language_holder()?.copy_languages(stored_language_holder)

		membrane_mur.Grant(brainmob)
		var/datum/antagonist/changeling/target_ling = brainmob?.mind?.has_antag_datum(/datum/antagonist/changeling)

		// TODO: convert these to use a signal or some shit ~Lucy
		if(target_ling && !HAS_TRAIT(brainmob.mind, TRAIT_NO_SPECIAL_REVIVAL))
			if(target_ling.oozeling_revives > 0)
				target_ling.oozeling_revives--
				to_chat(brainmob, span_changeling("You begin gathering your energy. You will revive in 30 seconds."))
				addtimer(CALLBACK(src, PROC_REF(rebuild_body), null, FALSE, POLICY_ANTAGONISTIC_REVIVAL), 30 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

		if(IS_BLOODSUCKER(brainmob) && !HAS_TRAIT(brainmob.mind, TRAIT_NO_SPECIAL_REVIVAL))
			var/datum/antagonist/bloodsucker/target_bloodsucker = brainmob.mind.has_antag_datum(/datum/antagonist/bloodsucker)
			if(target_bloodsucker.bloodsucker_blood_volume >= OOZELING_MIN_REVIVE_BLOOD_THRESHOLD)
				to_chat(brainmob, span_notice("You begin recollecting yourself. You will rise again in 3 minutes."))
				addtimer(CALLBACK(target_bloodsucker, TYPE_PROC_REF(/datum/antagonist/bloodsucker, oozeling_revive), src), 180 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)
				target_bloodsucker.bloodsucker_blood_volume -= (OOZELING_MIN_REVIVE_BLOOD_THRESHOLD * 0.5)

	if(stored_dna)
		rebuilt = FALSE
		victim.transfer_observers_to(src)

	qdel(victim)

	SEND_SIGNAL(mind, COMSIG_OOZELING_CORE_EJECTED, src)

/obj/item/organ/internal/brain/slime/proc/store_item_slots(mob/living/carbon/human/victim)
	items_per_slot = alist()
	// instantly retract any modsuits, to avoid jank
	if(istype(victim.back, /obj/item/mod/control))
		var/obj/item/mod/control/mod_control = victim.back
		for(var/obj/item/part as anything in mod_control.mod_parts)
			mod_control.retract(null, part)
	// also retract any deployables
	if(victim.wear_suit)
		var/datum/component/toggle_attached_clothing/hood_component = victim.wear_suit.GetComponent(/datum/component/toggle_attached_clothing)
		hood_component?.remove_deployable()
	for(var/obj/item/equipped as anything in victim.get_equipped_items(INCLUDE_POCKETS))
		if(equipped.item_flags & (DROPDEL | ABSTRACT | HAND_ITEM))
			continue
		if(HAS_TRAIT(equipped, TRAIT_NODROP))
			continue
		var/slot = victim.get_slot_by_item(equipped)
		if(slot)
			items_per_slot[equipped] = slot

/obj/item/organ/internal/brain/slime/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()

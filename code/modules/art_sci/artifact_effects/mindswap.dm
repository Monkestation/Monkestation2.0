/datum/artifact_effect/mindswap
	examine_hint = span_warning("The words 'I am you; you are me' are being projected into your mind...")
	examine_discovered = "Switches the minds of two nearby beings!"
	weight = ARTIFACT_VERYRARE
	research_value = TECHWEB_TIER_3_POINTS //wat
	discovered_credits = CARGO_CRATE_VALUE*20 //Assassinations anyone?
	type_name = "Mind Switch Effect"
	super_secret = TRUE

/datum/artifact_effect/mindswap/effect_activate(silent)
	var/owner_turf = get_turf(our_artifact.holder)
	if(owner_turf)
		var/mob/living/victimA
		var/mob/living/victimB
		for(var/mob/living/maybe in range(5,owner_turf))
			if(!maybe.key)
				continue
			if(!victimA)
				victimA = maybe
				continue
			if(victimA && !victimB)
				victimB = maybe
			if(victimA && victimB)
				swap_minds(victimA,victimB)
				break
	our_artifact?.artifact_deactivate()

/datum/artifact_effect/mindswap/proc/swap_minds(mob/living/caster, mob/living/cast_on)

	var/mob/living/to_swap = cast_on
	if(isguardian(cast_on))
		var/mob/living/basic/guardian/stand = cast_on
		if(stand.summoner)
			to_swap = stand.summoner

	var/datum/mind/mind_to_swap = to_swap.mind
	if(mind_to_swap.has_antag_datum(/datum/antagonist/wizard) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/rev) \
		|| mind_to_swap.key?[1] == "@" \
	)
		return FALSE

	// MIND TRANSFER BEGIN

	var/datum/mind/caster_mind = caster.mind
	var/datum/mind/to_swap_mind = to_swap.mind

	var/to_swap_key = to_swap.key

	caster_mind.transfer_to(to_swap)
	to_swap_mind.transfer_to(caster)

	// Just in case the swappee's key wasn't grabbed by transfer_to...
	if(to_swap_key)
		caster.PossessByPlayer(to_swap_key)
	// MIND TRANSFER END
	caster.Unconscious(5 SECONDS)
	to_swap.Unconscious(5 SECONDS)

	SEND_SOUND(caster, sound('sound/effects/magic/mandswap.ogg'))
	SEND_SOUND(to_swap, sound('sound/effects/magic/mandswap.ogg'))

	if(prob(20)) //No infinite random chaos mind swap sorry
		our_artifact?.holder?.visible_message("[our_artifact.holder] folds into oblivion!")
		qdel(our_artifact.holder)

	return TRUE

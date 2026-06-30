/datum/action/cooldown/spell/aoe/mind_swap
	name = "Mind Swap"
	desc = "This spell will randomly swap the minds of everyone around you, yourself included."
	button_icon_state = "mindswap"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 3 MINUTES
	cooldown_reduction_per_rank = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_MIND|SPELL_CASTABLE_AS_BRAIN
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER

	aoe_radius = 3

	/// If TRUE, we cannot mindswap into mobs with minds if they do not currently have a key / player.
	var/target_requires_key = TRUE
	/// If TRUE, we cannot mindswap into people without a mind.
	/// You may be wondering "What's the point of mindswap if the target has no mind"?
	/// Primarily for debugging - targets hit with this set to FALSE will init a mind, then do the swap.
	var/target_requires_mind = TRUE
	/// For how long are mobs stunned for after the spell
	var/unconscious_amount = 20 SECONDS
	/// List of mobs we cannot mindswap into.
	var/static/list/mob/living/blacklisted_mobs = typecacheof(list(
		/mob/living/brain,
		/mob/living/silicon/pai,
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/basic/guardian,
	))

/datum/action/cooldown/spell/aoe/mind_swap/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NO_MINDSWAP))
		if(feedback)
			to_chat(owner, span_warning("Your mind can't be swapped!"))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_SUICIDED))
		if(feedback)
			to_chat(owner, span_warning("You're killing yourself! You can't concentrate enough to do this!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/aoe/mind_swap/get_things_to_cast_on(atom/center)
	var/list/things = list()
	var/mob/living/caster_body
	for(var/mob/living/nearby_mob in range(aoe_radius, get_turf(center)))
		if(is_type_in_typecache(nearby_mob, blacklisted_mobs) || (nearby_mob.stat == DEAD))
			continue

		if(!caster_body && nearby_mob == owner)
			caster_body = nearby_mob
			continue

		if(target_requires_mind)
			if(!nearby_mob.mind)
				continue
		else if(!target_requires_mind && !nearby_mob.mind)
			nearby_mob.mind_initialize()

		if(!nearby_mob.key && target_requires_key)
			continue

		if(HAS_TRAIT(nearby_mob, TRAIT_MIND_TEMPORARILY_GONE) || HAS_MIND_TRAIT(nearby_mob, TRAIT_NO_MINDSWAP) || HAS_TRAIT(nearby_mob, TRAIT_SUICIDED))
			continue

		var/datum/mind/mind_to_swap = nearby_mob.mind
		if(nearby_mob.can_block_magic(antimagic_flags) || mind_to_swap.has_antag_datum(/datum/antagonist/wizard) || mind_to_swap.key?[1] == "@") //aghosted mobs
			continue

		things += nearby_mob

	if(!length(things))
		return things
	//to avoid more jank we just do the swapping in here
	shuffle_inplace(things)
	things.len++
	things[length(things)] = caster_body
	var/datum/mind/caster_mind = caster_body.mind
	for(var/i = (length(things) - 1), i > 0, --i)
		var/mob/living/current_mob = things[i]
		var/mob/living/next_mob = things[i + 1]
		current_mob.mind.transfer_to(next_mob, TRUE)
		SEND_SOUND(next_mob, sound('sound/magic/mandswap.ogg'))
		next_mob.Unconscious(unconscious_amount)
	caster_mind.transfer_to(things[1])
	caster_body = caster_mind.current
	caster_body.Unconscious(unconscious_amount)
	return things

/datum/action/cooldown/spell/aoe/mind_swap/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	return

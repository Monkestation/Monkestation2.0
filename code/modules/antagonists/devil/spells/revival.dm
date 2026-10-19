/datum/action/cooldown/spell/devil/revival
	name = "Devilish revival"
	desc = "Heals your body into great condition."
	button_icon_state = "sacredflame"
	sound = 'sound/magic/RATTLEMEBONES.ogg'
	school = SCHOOL_NECROMANCY
	cooldown_time = 5 MINUTES
	check_flags = NONE
	antimagic_flags = NONE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	/// Should we remove ourselfes after being activated?
	var/one_time = FALSE
	/// The flags we heal with, very similar to changeling revive, but no limbs
	var/heal_flags = (HEAL_DAMAGE|HEAL_BODY|HEAL_AFFLICTIONS) & ~HEAL_LIMBS

/datum/action/cooldown/spell/devil/revival/IsAvailable(feedback = FALSE) // Bit long but like we aren't using anything from ..
	return owner && is_valid_target(owner) && (next_use_time <= world.time) && can_cast_spell(feedback)

/datum/action/cooldown/spell/devil/revival/can_cast_spell(feedback = TRUE)
	if(is_oozeling_core(owner.loc))
		return TRUE
	return ..()

/datum/action/cooldown/spell/devil/revival/get_caster_from_target(atom/target)
	if(is_oozeling_core(owner.loc))
		return target
	return ..()

/datum/action/cooldown/spell/devil/revival/cast(mob/living/cast_on)
	. = ..()
	cast_on.visible_message(
		span_danger("[cast_on] bursts into flames, as their body rapidly grows back flesh!"),
		span_notice("You come back to life using the otherwordly contract!"),
	)
	if(!is_oozeling_core(owner.loc))
		cast_on.revive(heal_flags, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	else
		var/obj/item/organ/internal/brain/slime/ooze = owner.loc
		var/mob/living/new_body = ooze.rebuild_body(null, !(heal_flags & HEAL_LIMBS), POLICY_ANTAGONISTIC_REVIVAL)
		if(new_body)
			new_body.set_nutrition(NUTRITION_LEVEL_FED) // The nugget option is a bit extreme, so give em nutrition
	if(one_time)
		qdel(src)

/datum/action/cooldown/spell/devil/revival/greater
	name = "Greater devilish revival"
	heal_flags = (HEAL_DAMAGE|HEAL_BODY|HEAL_AFFLICTIONS)

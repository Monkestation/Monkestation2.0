// This spell exists mainly for debugging purposes, and also to show how casting works
/datum/action/cooldown/spell/self_destruct
	name = "Self Destruct"
	desc = "Bathes your body in a red white hot sun, dusting it immediately."

	sound = 'sound/magic/wandodeath.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/self_destruct/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/self_destruct/cast(mob/living/cast_on)
	. = ..()
	new /obj/effect/decal/remains/human(cast_on.loc)
	cast_on.ghostize()
	qdel(cast_on)

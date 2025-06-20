/datum/material_trait/holy
	name = "Holy"
	desc = "This item does extra damage against unholy beings."
	trait_flags = MT_NO_STACK_ADD
	value_bonus = 25

/datum/material_trait/holy/post_parent_init(obj/item/parent)
	if(!isitem(parent))
		return
	// DO NOT DOUBLE APPLY THIS!!!
	if(locate(/datum/material_trait/holy) in parent.material_stats?.material_traits - src)
		return
	RegisterSignal(parent, COMSIG_ITEM_DAMAGE_MULTIPLIER, PROC_REF(damage_multiplier))

/datum/material_trait/holy/proc/damage_multiplier(obj/item/source, damage_multiplier_ptr, mob/living/victim, def_zone)
	SIGNAL_HANDLER
	if(IS_BLOODSUCKER(victim))
		// negate the damage reduction from fortitude
		if(HAS_TRAIT_FROM(victim, TRAIT_PIERCEIMMUNE, FORTITUDE_TRAIT) && source.damtype == BRUTE)
			var/datum/physiology/physiology = astype(victim, /mob/living/carbon/human)?.physiology
			if(physiology)
				*damage_multiplier_ptr /= physiology.brute_mod

		// extra damage during sol
		if(victim.has_status_effect(/datum/status_effect/bloodsucker_sol))
			*damage_multiplier_ptr *= 2
		else
			*damage_multiplier_ptr *= 1.5

	// werewolves have insane damage resistance, so 3x damage
	if(iswerewolf(victim))
		*damage_multiplier_ptr *= 3
	else if(isvampire(victim))
		*damage_multiplier_ptr *= 1.5


/datum/material_trait/holy/proc/is_unholy_target(mob/living/victim)
	if(isvampire(victim) || iswerewolf(victim))
		return TRUE
	if(IS_BLOODSUCKER(victim))
		return TRUE
	return FALSE

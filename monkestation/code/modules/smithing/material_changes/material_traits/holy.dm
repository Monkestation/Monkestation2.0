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
	RegisterSignal(parent, COMSIG_ITEM_DAMAGE_MULTIPLIER, PROC_REF(apply_damage_multiplier))

/datum/material_trait/holy/proc/apply_damage_multiplier(obj/item/source, damage_multiplier_ptr, mob/living/victim, def_zone)
	SIGNAL_HANDLER
	var/damage_multiplier = 1
	if(IS_BLOODSUCKER(victim))
		// extra damage during sol
		if(victim.has_status_effect(/datum/status_effect/bloodsucker_sol))
			damage_multiplier *= 3
		else
			damage_multiplier *= 2

	// werewolves have insane damage resistance, so 3x damage
	if(iswerewolf(victim))
		damage_multiplier *= 5
	else if(isvampire(victim))
		damage_multiplier *= 2

	if(damage_multiplier != 1)
		// negate physiology damage modifiers (i.e fortitude)
		var/datum/physiology/physiology = astype(victim, /mob/living/carbon/human)?.physiology
		if(physiology)
			var/phys_mod = 1
			switch(source.damtype)
				if(BRUTE)
					phys_mod = physiology.brute_mod
				if(BURN)
					phys_mod = physiology.burn_mod
				if(TOX)
					phys_mod = physiology.tox_mod
				if(OXY)
					phys_mod = physiology.oxy_mod
				if(CLONE)
					phys_mod = physiology.clone_mod
				if(STAMINA)
					phys_mod = physiology.stamina_mod
			if(phys_mod < 1)
				damage_multiplier /= phys_mod

		// negate bodypart damage modifiers
		var/obj/item/bodypart/affecting = astype(def_zone) || victim.get_bodypart(check_zone(def_zone))
		if(affecting)
			var/part_mod = 1
			if(source.damtype == BRUTE)
				part_mod = affecting.brute_modifier
			else if(source.damtype == BURN)
				part_mod = affecting.burn_modifier
			if(part_mod < 1)
				damage_multiplier /= part_mod

		*damage_multiplier_ptr *= damage_multiplier

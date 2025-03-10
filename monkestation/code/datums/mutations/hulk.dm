/datum/mutation/human/hulk
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/hulk/modify()
	. = ..()
	if(isnull(owner))
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.cold_mod *= (GET_MUTATION_SYNCHRONIZER(src) * 1.5)
		owner.bodytemp_cold_damage_limit -= (BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER * GET_MUTATION_SYNCHRONIZER(src))

	if(GET_MUTATION_POWER(src) <= 1)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] += (10 * GET_MUTATION_POWER(src))
	armorlist[BULLET] += (10 * GET_MUTATION_POWER(src))

	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.cold_mod /= (GET_MUTATION_SYNCHRONIZER(src) * 1.5)
		owner.bodytemp_cold_damage_limit += (BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER * GET_MUTATION_SYNCHRONIZER(src))

	if(GET_MUTATION_POWER(src) <= 1)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] -= (10 * GET_MUTATION_POWER(src))
	armorlist[BULLET] -= (10 * GET_MUTATION_POWER(src))

	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

/datum/mutation/human/geladikinesis
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/geladikinesis/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/conjure_item/snow/modified_power = .
	modified_power.amount_to_make = GET_MUTATION_POWER(src) != 1 ? floor(GET_MUTATION_POWER(src) * 2) : 1

/datum/action/cooldown/spell/conjure_item/snow
	/// How much extra snow we make
	var/amount_to_make = 1

/datum/action/cooldown/spell/conjure_item/snow/make_item(atom/caster)
	var/obj/item/stack/made_item = new item_type(null) // Yes, we make it in nullspace. This CANNOT merge before we're ready
	if(istype(made_item))
		made_item.amount = amount_to_make
	return made_item

/datum/action/cooldown/spell/conjure_item/snow/post_created(atom/cast_on, obj/created)
	if(isnull(created.loc))
		created.forceMove(get_turf(cast_on))

/datum/mutation/human/cryokinesis
	power_coeff = 1

/datum/mutation/human/cryokinesis/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/pointed/projectile/cryo/modified_power = .
	modified_power.projectiles_per_fire = GET_MUTATION_POWER(src) != 1 ? floor(GET_MUTATION_POWER(src) * 1.5) : 1

/datum/action/cooldown/spell/pointed/projectile/cryo/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(projectiles_per_fire > 1)
		var/current_angle = iteration * 30
		to_fire.preparePixelProjectile(target, user, null, current_angle - 45)

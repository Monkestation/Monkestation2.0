/datum/mutation/geladikinesis
	name = "Geladikinesis"
	desc = "Allows the user to concentrate moisture and sub-zero forces into snow."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your hand feels cold.</span>"
	instability = 10
	difficulty = 10
	power_coeff = 1
	energy_coeff = 1
	power_path = /datum/action/cooldown/spell/conjure_item/snow

/datum/mutation/geladikinesis/setup()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/conjure_item/snow/modified_power = .
	modified_power.amount_to_make = GET_MUTATION_POWER(src) != 1 ? floor(GET_MUTATION_POWER(src) * 2) : 1

/datum/action/cooldown/spell/conjure_item/snow
	name = "Create Snow"
	desc = "Concentrates cryokinetic forces to create snow, useful for snow-like construction."
	button_icon_state = "snow"

	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	item_type = /obj/item/stack/sheet/mineral/snow
	delete_old = FALSE
	delete_on_failure = FALSE

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

/datum/mutation/cryokinesis
	name = "Cryokinesis"
	desc = "Draws negative energy from the sub-zero void to freeze surrounding temperatures at subject's will."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>Your hand feels cold.</span>"
	instability = 30
	difficulty = 12
	power_coeff = 1
	energy_coeff = 1
	power_path = /datum/action/cooldown/spell/pointed/projectile/cryo

/datum/mutation/cryokinesis/setup()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/pointed/projectile/cryo/modified_power = .
	modified_power.projectiles_per_fire = GET_MUTATION_POWER(src) != 1 ? floor(GET_MUTATION_POWER(src) * 1.5) : 1

/datum/action/cooldown/spell/pointed/projectile/cryo
	name = "Cryobeam"
	desc = "This power fires a frozen bolt at a target."
	button_icon_state = "icebeam"
	base_icon_state = "icebeam"
	active_overlay_icon_state = "bg_spell_border_active_blue"
	cooldown_time = 16 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE

	active_msg = "You focus your cryokinesis!"
	deactive_msg = "You relax."
	projectile_type = /obj/projectile/temp/cryo

/datum/action/cooldown/spell/pointed/projectile/cryo/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(projectiles_per_fire > 1)
		var/current_angle = iteration * 30
		to_fire.aim_projectile(target, user, null, current_angle - 45)

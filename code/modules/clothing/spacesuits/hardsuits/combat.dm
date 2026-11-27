//-------------------
// Security Hardsuit
//-------------------
/obj/item/clothing/suit/space/hardsuit/sec
	name = "security hardsuit"
	desc = "A special suit designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit-sec"
	armor_type = /datum/armor/hardsuit/sec
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/sec
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/gun/microfusion,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/belt/holster/detective,
		/obj/item/storage/belt/holster/nukie,
		/obj/item/storage/belt/holster/energy,
		/obj/item/clothing/mask/breath/sec_bandana,
	)

/obj/item/clothing/head/helmet/space/hardsuit/sec
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	armor_type = /datum/armor/hardsuit/sec
	hardsuit_type = "sec"

/obj/item/clothing/head/helmet/space/hardsuit/sec/New(loc, ...)
	. = ..()
	hud_glasses = new /obj/item/clothing/glasses/hud/security(src)

/obj/item/clothing/suit/space/hardsuit/sec/prototype
	name = "prototype security hardsuit"
	desc = "A prototype security suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous operations. It's loaded with expensive electronics inside."
	icon_state = "hardsuit-prototype"
	armor_type = /datum/armor/hardsuit/sec_prototype
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/sec/prototype
	slowdown = 3
	hardsuit_emp_burn = 20
	hardsuit_emp_knockdown = 15 SECONDS
	actions_types = list(/datum/action/item_action/toggle_spacesuit/shield)
	thermal_regulator_cost = (0.1 * STANDARD_CELL_CHARGE)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | BLOCKS_SHOVE_KNOCKDOWN

/obj/item/clothing/suit/space/hardsuit/sec/prototype/process(seconds_per_tick)
	var/mob/living/carbon/human/user = loc
	if(!user || !ishuman(user) || user.wear_suit != src)
		return

	// Do nothing if thermal regulators are off
	if(!thermal_on)
		return

	// If we got here, thermal regulators are on. If there's no cell, turn them off
	if(!cell)
		toggle_spacesuit(user)
		update_hud_icon(user)
		return

	// cell.use will return FALSE if charge is lower than THERMAL_REGULATOR_COST
	if(!cell.use(thermal_regulator_cost))
		toggle_spacesuit(user)
		update_hud_icon(user)
		to_chat(user, span_warning("The electronics on [src] shut down as [cell] runs out of charge."))
		return

	// If we got here, it means thermals are on, the cell is in and the cell has
	// just had enough charge subtracted from it to power the thermal regulator
	user.adjust_bodytemperature(get_temp_change_amount((temperature_setting - user.bodytemperature), 0.08 * seconds_per_tick))
	update_hud_icon(user)

/// Toggle the space suit's thermal regulator status
/obj/item/clothing/suit/space/hardsuit/sec/prototype/toggle_spacesuit(mob/toggler)
	// If we're turning thermal protection on, check for valid cell and for enough
	// charge that cell. If it's too low, we shouldn't bother with setting the
	// thermal protection value and should just return out early.
	if(!thermal_on && (!cell || cell.charge < thermal_regulator_cost))
		if(toggler)
			to_chat(toggler, span_warning("The electronics on [src] have no charge."))
		return
	thermal_on = !thermal_on
	min_cold_protection_temperature = thermal_on ? SPACE_SUIT_MIN_TEMP_PROTECT : SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	slowdown = thermal_on ? 1 : 3
	if(ishuman(loc))
		var/mob/living/carbon/human/wielder = loc
		if(wielder.wear_suit)
			wielder.update_equipment_speed_mods()

	if(toggler)
		to_chat(toggler, span_notice("You turn [thermal_on ? "on" : "off"] [src]'s electronics."))

	update_item_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/sec/prototype
	name = "prototype security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has an additional heavy layer of armor. Security data flashes across the visor."
	icon_state = "hardsuit0-prototype"
	armor_type = /datum/armor/hardsuit/sec_prototype
	hardsuit_type = "prototype"
	slowdown = 1

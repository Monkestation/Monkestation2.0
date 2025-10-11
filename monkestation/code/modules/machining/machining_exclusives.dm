// The makeshift pulse gun uses the backpack style. So its better here then in the pulse catagory, since backpack is more cooler about it.
/obj/item/pulsepack
	name = "Backpack pulse generator"
	desc = "A pack that converts extreme amounts of power into pre pulse fusion products. Unable to be minaturized due to a lack of technology."
	icon = 'icons/obj/weapons/guns/minigun.dmi'
	worn_icon = 'icons/mob/clothing/back/backpack.dmi'
	worn_icon_state = "pulsepack"
	icon_state = "holsteredp"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	inhand_icon_state = "pepperbackpacksec" //close enough
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	///The actual gun that you draw when you use it
	var/obj/item/gun/energy/pulse/makeshift/gun
	///batteries of the pulsepack
	var/obj/item/stock_parts/power_store/cell/pulsepack/battery
	///whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/armed = FALSE
	///used the gun too much?
	var/overheat = 0
	/// maximum amount of overheat
	var/overheat_max = 1
	///how much heat is dissipated (read: how long it takes to reload)
	var/heat_diffusion = 0.13


/obj/item/pulsepack/Initialize(mapload)
	. = ..()
	gun = new(src)
	battery = new(src)
	START_PROCESSING(SSobj, src)

/obj/item/pulsepack/Destroy()
	//we do this check as a precaution (read: pass checks) since the backpack itself should have already deleted this
	if(!QDELETED(gun))
		qdel(gun)
	gun = null
	QDEL_NULL(battery)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/pulsepack/process(seconds_per_tick)
	overheat = max(0, overheat - heat_diffusion * seconds_per_tick)

/obj/item/pulsepack/attack_hand(mob/living/carbon/user, list/modifiers)
	if(armed)
		to_chat(user, span_warning("You are already holding the gun!"))
		return

	if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
		armed = TRUE
		if(!user.put_in_hands(gun))
			armed = FALSE
			to_chat(user, span_warning("You need a free hand to hold the gun!"))
			return
		update_appearance()
		user.update_worn_back()
		return

	return . = ..()

/obj/item/pulsepack/item_interaction(mob/living/user, obj/item/weapon, list/modifiers)
	. = ..()
	if(weapon == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		return ..()


/obj/item/pulsepack/dropped(mob/user)
	. = ..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/pulsepack/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(armed || !iscarbon(user) || !over_location || user.incapacitated() || !istype(over_location, /atom/movable/screen/inventory/hand))
		return
	var/atom/movable/screen/inventory/hand/user_hand = over_location
	user.putItemFromInventoryInHandIfPossible(src, user_hand.held_index)

/obj/item/pulsepack/update_icon_state()
	icon_state = armed ? "notholsteredp" : "holsteredp"
	return ..()

/obj/item/pulsepack/proc/attach_gun(mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	if(user)
		to_chat(user, span_notice("You attach the [gun.name] to the [name]."))
	else
		visible_message(span_warning("The [gun.name] snaps back onto the [name]!"))
	update_appearance()
	user.update_worn_back()


/obj/item/gun/energy/pulse/makeshift
	name = "Pulse caster"
	desc = "More a set of aiming lenses, focuses the power generated from the pulse generator into deadly beams."
	icon = 'icons/obj/weapons/guns/minigun.dmi'
	icon_state = "pulsecaster"
	inhand_icon_state = "pulsecaster"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	slowdown = 1
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	custom_materials = null
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)
	cell_type = /obj/item/stock_parts/power_store/cell/pulsepack
	item_flags = SLOWS_WHILE_IN_HAND
	can_charge = FALSE
	///the backpack we are linked to
	var/obj/item/pulsepack/ammo_pack

/obj/item/gun/energy/pulse/makeshift/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/pulsepack)) //We should spawn inside an ammo pack so let's use that one.
		return INITIALIZE_HINT_QDEL //No pack, no gun
	ammo_pack = loc
	AddElement(/datum/element/update_icon_blocker)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/energy/pulse/makeshift/Destroy()
	//we do this check as a precaution (read: pass checks) since the backpack itself should have already deleted this
	if(!QDELETED(ammo_pack))
		qdel(ammo_pack)
	ammo_pack = null
	return ..()

/obj/item/gun/energy/pulse/makeshift/attack_self(mob/living/user)
	return

/obj/item/gun/energy/pulse/makeshift/dropped(mob/user)
	if(!ammo_pack)
		qdel(src)
		return
	ammo_pack.attach_gun(user)
	return ..()

/obj/item/gun/energy/pulse/makeshift/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack && ammo_pack.overheat >= ammo_pack.overheat_max)
		to_chat(user, span_warning("The pulse pack is still generating plasma!"))
		return
	..()
	ammo_pack.overheat++
	if(ammo_pack.battery)
		var/totransfer = min(100, ammo_pack.battery.charge)
		var/transferred = cell.give(totransfer)
		ammo_pack.battery.use(transferred)


/obj/item/gun/energy/pulse/makeshift/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, span_warning("You need the backpack power source to fire the gun!"))
	. = ..()

/obj/item/stock_parts/power_store/cell/pulsepack
	name = "Pulse pack fusion core"
	desc = "Exposed fusion product outside of containment field on an already sketchy ass power pack. \
		There should be no reason you have this, and honestly you should tell an admin if you somehow got this, \
		I'm too fucking lazy to code in an explosion if you somehow have this in your hand so good job, you broke the game. \
		Now get back to beating the ERPers into a pulp spessman. Your server depends on you."
	maxcharge = STANDARD_CELL_CHARGE * 500
	chargerate = STANDARD_CELL_RATE * 5

//mecha armor plates
/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part
	name = "Hardened Exosuit Part"
	desc = "Hardened internal parts that boosts the maximum exosuit internal integrity of an exosuit, it appears to be custom-made"
	icon_state = "mecha_abooster_proj"
	iconstate_name = "shield"
	protect_name = "Extra Integrity"
	icon = 'monkestation/icons/obj/machining_intermediates.dmi'
	icon_state = "hardenedexosuit_part"
	armor_mod = /datum/armor/mecha_equipment_parts
	var/extra_integrity_mod = 1.25
	var/applied_integrity

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part/forged
	name = "Forged Exosuit Part"
	desc = "Forged internal parts that greatly boosts the maximum exosuit internal integrity of an exosuit, it appears to be custom-made"
	extra_integrity_mod = 1.5

/datum/armor/mecha_equipment_parts
	melee = 5 //very minimal armor, the integrity is the main reason you'd want it

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mech, attach_right)
	for(var/obj/item/item in mech.equip_by_category[MECHA_ARMOR])
		if(istype(item, src))
			to_chat(user, span_warning("[mech] already has custom internal parts! Uninstall them before applying."))
			return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right)
	. = ..()
	applied_integrity = initial(chassis.max_integrity) * (extra_integrity_mod - 1)
	chassis.max_integrity += applied_integrity

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part/detach(atom/moveto)
	. = ..()
	chassis.max_integrity -= applied_integrity

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate
	name = "Hardened Exosuit Part"
	desc = "Hardened armoured plates that hardens the protection of an exosuit, it appears to be custom-made"
	icon = 'monkestation/icons/obj/machining_intermediates.dmi'
	icon_state = "hardenedexosuit_plate"
	armor_mod = /datum/armor/mecha_machined_armor

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mech, attach_right)
	for(var/obj/item/item in mech.equip_by_category[MECHA_ARMOR])
		if(istype(item, src))
			to_chat(user, span_warning("[mech] already has custom internal parts! Uninstall them before applying."))
			return FALSE
	return ..()

/datum/armor/mecha_machined_armor
	melee = 15
	laser = 15
	bullet = 15
	energy = 15

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate/forged
	name = "Forged Exosuit Part"
	desc = "Forged armoured plates that greatly hardens the protection of an exosuit, it appears to be custom-made"
	icon = 'monkestation/icons/obj/machining_intermediates.dmi'
	icon_state = "forgedexosuit_plate"
	armor_mod = /datum/armor/mecha_machined_armor_forged

/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate/forged/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mech, attach_right)
	for(var/obj/item/item in mech.equip_by_category[MECHA_ARMOR])
		if(istype(item, src))
			to_chat(user, span_warning("[mech] already has custom internal parts! Uninstall them before applying."))
			return FALSE
	return ..()

/datum/armor/mecha_machined_armor_forged
	melee = 25
	laser = 25
	bullet = 25
	energy = 25

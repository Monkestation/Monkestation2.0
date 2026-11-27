

//The ammo/gun is stored in a back slot item
/obj/item/minigunpack
	name = "backpack power source"
	desc = "The massive external power source for the laser gatling gun."
	icon = 'icons/obj/weapons/guns/minigun.dmi'
	icon_state = "holstered"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 1

	var/obj/item/gun/energy/minigun/gun
	var/obj/item/stock_parts/power_store/cell/minigun/battery
	var/armed = FALSE //whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 50
	var/heat_diffusion = 1

	/// The amount of time between instances of self recharge
	var/charge_timer = 0
	/// The amount of seconds_per_tick during process() before the battery charges itself
	var/charge_delay = 8
	/// The amount restored by to the battery per tick
	var/self_charge_amount = STANDARD_ENERGY_GUN_SELF_CHARGE_RATE

/obj/item/minigunpack/Initialize(mapload)
	. = ..()
	gun = new(src)
	battery = new(src)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/drag_pickup)

/obj/item/minigunpack/Destroy()
	if(!QDELETED(gun))
		qdel(gun)
	gun = null
	QDEL_NULL(battery)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/minigunpack/process(seconds_per_tick)
	overheat = max(0, overheat - heat_diffusion * seconds_per_tick)
	if(battery && battery.percent() < 100)
		charge_timer += seconds_per_tick
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		battery.give(self_charge_amount * seconds_per_tick)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigunpack/attack_hand(mob/living/carbon/user, list/modifiers)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = TRUE
				if(!user.put_in_hands(gun))
					armed = FALSE
					to_chat(user, span_warning("You need a free hand to hold the gun!"))
					return
				update_appearance()
				user.update_worn_back()
		else
			to_chat(user, span_warning("You are already holding the gun!"))
	else
		..()

/obj/item/minigunpack/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigunpack/dropped(mob/user)
	. = ..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/minigunpack/update_icon_state()
	icon_state = armed ? "notholstered" : "holstered"
	return ..()

/obj/item/minigunpack/proc/attach_gun(mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	var/transferred = battery.use(gun.cell.maxcharge - gun.cell.charge, force = TRUE)
	gun.cell.give(transferred)
	if(user)
		to_chat(user, span_notice("You attach the [gun.name] to the [name]."))
	else
		src.visible_message(span_warning("The [gun.name] snaps back onto the [name]!"))
	update_appearance()
	user.update_worn_back()

/obj/item/minigunpack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/mob/living/carbon/human/user = get(loc, /mob/living)
	if(!istype(user))
		return
	user.electrocute_act(shock_damage = 20, source = src, flags = SHOCK_NOGLOVES)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	if(prob(70))
		user.apply_damage(25, BURN, spread_damage=TRUE)
		to_chat(user, span_warning("\The [src] overloads!"))
	else
		playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 40, FALSE)
		user.apply_damage(75, BURN, spread_damage=TRUE)
		to_chat(user, span_warning("\The [src] overloads and fails catastrophically!"))
		user.Paralyze(10 SECONDS)
		sleep(1 SECONDS)
		tesla_zap(src, 2, battery.charge, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_LOW_POWER_GEN | ZAP_ALLOW_DUPLICATES)
		user.adjust_fire_stacks(2)
		user.ignite_mob()
	if(user.stat < UNCONSCIOUS)
		user.emote("scream")

/obj/item/gun/energy/minigun
	name = "laser gatling gun"
	desc = "An advanced laser cannon with an incredible rate of fire. Requires a bulky backpack power source to use."
	icon = 'icons/obj/weapons/guns/minigun.dmi'
	icon_state = "minigun_spin"
	inhand_icon_state = "minigun"
	slowdown = 1
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	custom_materials = null
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/laser/minigun, /obj/item/ammo_casing/energy/disabler/minigun)
	cell_type = /obj/item/stock_parts/power_store/cell/crap
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	can_charge = FALSE
	var/obj/item/minigunpack/ammo_pack
	spread = 15

/obj/item/gun/energy/minigun/Initialize(mapload)
	if(!istype(loc, /obj/item/minigunpack)) //We should spawn inside an ammo pack so let's use that one.
		return INITIALIZE_HINT_QDEL //No pack, no gun
	ammo_pack = loc
	AddElement(/datum/element/update_icon_blocker)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)
	return ..()

/obj/item/gun/energy/minigun/Destroy()
	if(!QDELETED(ammo_pack))
		qdel(ammo_pack)
	ammo_pack = null
	return ..()

/obj/item/gun/energy/minigun/dropped(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/gun/energy/minigun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack && ammo_pack.overheat >= ammo_pack.overheat_max)
		to_chat(user, span_warning("The gun's heat sensor locked the trigger to prevent lens damage!"))
		return
	..()
	ammo_pack.overheat++
	if(ammo_pack.battery)
		var/transferred = ammo_pack.battery.use(cell.maxcharge - cell.charge, force = TRUE)
		cell.give(transferred)


/obj/item/gun/energy/minigun/try_fire_gun(atom/target, mob/living/user, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, span_warning("You need the backpack power source to fire the gun!"))
		return FALSE
	return ..()

/obj/item/stock_parts/power_store/cell/minigun
	name = "gatling gun fusion core"
	desc = "Where did these come from?"
	maxcharge = 500 * STANDARD_CELL_CHARGE
	chargerate = 5 * STANDARD_CELL_CHARGE

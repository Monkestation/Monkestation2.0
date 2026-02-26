/obj/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foamdart_proj"
	base_icon_state = "foamdart_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/projectile/bullet/reusable/foam_dart/handle_drop(cancel=TRUE)
	if(dropped || cancel)
		return
	var/turf/T = get_turf(src)
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newcasing = new ammo_type(T)
	newcasing.modified = modified
	var/obj/projectile/bullet/reusable/foam_dart/newdart = newcasing.loaded_projectile
	newdart.modified = modified
	newdart.damage_type = damage_type
	if(pen)
		newdart.pen = pen
		pen.forceMove(newdart)
		pen = null
		newdart.damage = 5
	newdart.update_appearance()


/obj/projectile/bullet/reusable/foam_dart/Destroy()
	pen = null
	return ..()

/obj/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot_proj"
	base_icon_state = "foamdart_riot_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 11.5

/obj/projectile/bullet/reusable/foam_dart/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/carbon/ctarget = target
	if (. != BULLET_ACT_HIT || blocked != 0 || (def_zone != BODY_ZONE_PRECISE_MOUTH && def_zone != BODY_ZONE_HEAD && def_zone != BODY_ZONE_PRECISE_EYES) || !istype(ctarget))
		handle_drop(cancel=FALSE)
		return
	if(!ctarget.has_mouth() || ctarget.is_mouth_covered(ITEM_SLOT_HEAD) || ctarget.is_mouth_covered(ITEM_SLOT_MASK) || ctarget.has_status_effect(/datum/status_effect/choke))
		handle_drop(cancel=FALSE)
		return
	var/inhale_prob = def_zone == BODY_ZONE_PRECISE_MOUTH ? 15 : 5
	if(istype(src, /obj/projectile/bullet/reusable/foam_dart/riot))
		inhale_prob *= 2
	if((prob(inhale_prob) && hits_front(target)) || HAS_TRAIT(target, TRAIT_CURSED))
		var/obj/item/ammo_casing/caseless/foam_dart/item = new ammo_type
		item.inhale(target)

/obj/projectile/bullet/reusable/foam_dart/proc/hits_front(mob/target)
	if(target.flags_1 & IS_SPINNING_1 || !starting)
		return TRUE

	if(target.loc == starting)
		return FALSE

	var/target_to_starting = get_dir(target, starting)
	var/target_dir = target.dir
	return target_dir & target_to_starting

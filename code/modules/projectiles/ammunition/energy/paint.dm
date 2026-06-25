/obj/item/ammo_casing/energy/paint
	name = "paint concentrator"
	desc = "Concentrates paint into a solid projectile."
	caliber = BULLET //close enough
	projectile_type = /obj/projectile/paintball
	can_be_printed = FALSE
	select_name = "paintball"
	e_cost = 1
	variance = 3
	fire_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg' //todo: better sound for this

/obj/item/ammo_casing/energy/paint/ready_proj(atom/target, mob/living/user, quiet, zone_override, obj/item/gun/energy/paint_gun/fired_from)
	if(!loaded_projectile)
		return

	if(!istype(fired_from))
		return ..()

	loaded_projectile.color = fired_from.canister?.stored_paint_color
	return ..()

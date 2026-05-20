/obj/item/ammo_casing/energy/paint
	name = "paint concentrator"
	desc = "Concentrates paint into a solid projectile."
	caliber = BULLET //close enough
	projectile_type = /obj/projectile/paintball
	select_name = "paintball"
	e_cost = 1
	fire_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg' //todo: better sound for this

/obj/item/ammo_casing/energy/paint/ready_proj(atom/target, mob/living/user, quiet, zone_override, obj/item/gun/energy/paint_gun/fired_from)
	if(!loaded_projectile)
		return

	if(!istype(fired_from))
		return ..()

	/*var/obj/projectile/magic/change/change_projectile = loaded_projectile
	if(istype(change_staff) && istype(change_projectile))
		change_projectile.set_wabbajack_effect = change_staff.preset_wabbajack_type
		change_projectile.set_wabbajack_changeflags = change_staff.preset_wabbajack_changeflag*/

	return ..()

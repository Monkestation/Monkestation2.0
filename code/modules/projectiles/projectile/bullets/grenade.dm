// 40mm (Grenade Launcher

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	embedding = null
	shrapnel_type = null

//MONKESTATION EDIT START
/obj/projectile/bullet/a40mm/proc/explosive_power(atom/target)
	explosion(target, devastation_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 2, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosive_power(target)
	return BULLET_ACT_HIT
//MONKESTATION EDIT STOP

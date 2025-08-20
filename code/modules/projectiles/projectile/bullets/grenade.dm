// 40mm (Grenade Launcher

//MONKESTATION REMOVAL: moved to 40mm_grenade.dm
// /obj/projectile/bullet/a40mm
// 	name ="40mm grenade"
// 	desc = "USE A WEEL GUN"
// 	icon_state= "bolter"
// 	damage = 60
// 	embedding = null
// 	shrapnel_type = null

// /obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
// 	..()
// 	explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 1, adminlog = FALSE, explosion_cause = src)
// 	return BULLET_ACT_HIT

/obj/projectile/bullet/c980grenade
	name = ".980 Tydhouer practice grenade"
	damage = 20
	stamina = 30
	range = 14
	speed = 2 // Higher means slower, y'all
	sharpness = NONE

/obj/projectile/bullet/c980grenade/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	fuse_activation(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/c980grenade/on_range()
	fuse_activation(get_turf(src))
	return ..()

/// Generic proc that is called when the projectile should 'detonate', being either on impact or when the range runs out
/obj/projectile/bullet/c980grenade/proc/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	do_sparks(3, FALSE, src)


/obj/projectile/bullet/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"

/obj/projectile/bullet/c980grenade/smoke/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()


/obj/projectile/bullet/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	/// What type of casing should we put inside the bullet to act as shrapnel later
	var/casing_to_spawn = /obj/item/grenade/c980payload

/obj/projectile/bullet/c980grenade/shrapnel/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new casing_to_spawn(get_turf(src))

	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)


/obj/item/grenade/c980payload
	shrapnel_type = /obj/projectile/bullet/shrapnel/short_range
	shrapnel_radius = 2
	ex_dev = 0
	ex_heavy = 0
	ex_light = 0
	ex_flame = 0

/obj/projectile/bullet/shrapnel/short_range
	range = 2


/obj/projectile/bullet/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"

	casing_to_spawn = /obj/item/grenade/c980payload/phosphor

/obj/projectile/bullet/c980grenade/shrapnel/phosphor/fuse_activation(atom/target)
	. = ..()

	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/quick/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()

/obj/item/ammo_casing/shrapnel_exploder/phosphor
	pellets = 8
	projectile_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range

/obj/item/grenade/c980payload/phosphor
	shrapnel_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range

/obj/projectile/bullet/incendiary/fire/backblast/short_range
	range = 2


/obj/projectile/bullet/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"

/obj/projectile/bullet/c980grenade/riot/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new()
	smoke.chemholder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()

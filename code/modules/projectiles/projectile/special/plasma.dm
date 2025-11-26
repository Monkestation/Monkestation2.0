/obj/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BURN
	damage = 5
	range = 4
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/mine_range = 3 //mines this many additional tiles of rock
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter

/obj/projectile/plasma/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE

/obj/projectile/plasma/adv
	damage = 7
	range = 5
	mine_range = 5

/obj/projectile/plasma/adv/mech
	damage = 10
	range = 9
	mine_range = 3

/obj/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE


/obj/projectile/plasma/minerjdj //is plasma because wall cutting
	name = ".950 JDJ Kinetic solid brass projectile"
	desc = "you have somehow observed pure death, and it strikes fear that weaves deep within your psyche."
	speed = 0.2
	damage = 2500 //(EXPERIMENTAL) it costs like fucking over 40k points just to buy the rifle, lets test making it just delete one boss of your choice (and the loot potentially :)
	dismemberment = 100 //yeah no if you get hit by this its so over
	damage_type = BRUTE
	armor_flag = BULLET //not that it will save you...
	range = 50
	icon_state = "gaussstrong"
	tracer_type = ""
	muzzle_type = ""
	impact_type = ""
	mine_range = 1
	projectile_piercing = PASSMOB


/obj/projectile/plasma/kineticshotgun //subtype of plasma instead of kinetic so it can punch through mineable turf. Cant be used off of lavaland or off the wastes of icemoon anyways so...
	name = "magnum kinetic projectile"
	icon_state = "cryoshot"
	damage_type = BRUTE
	damage = 35  //totals 175 damage letting them reach the breakpoint for watcher HP so it one shots them
	range = 7
	dismemberment = 0
	projectile_piercing = PASSMOB
	impact_effect_type = /obj/effect/temp_visual/kinetic_blast
	mine_range = 1
	tracer_type = ""
	muzzle_type = ""
	impact_type = ""

/obj/projectile/plasma/kineticshotgun/sniperslug // long range but cant hit the oneshot breakpoint of a watcher and does not penetrate targets
	name = ".50 BMG kinetic"
	speed = 0.4
	damage = 150
	range = 10
	icon_state = "gaussstrong"
	projectile_piercing = NONE

/obj/projectile/plasma/kineticshotgun/rockbreaker // for breaking rocks
	name = "kinetic rockbreaker"
	speed = 1 //slower than average
	damage = 2
	range = 13
	icon_state = "guardian"
	projectile_piercing = NONE


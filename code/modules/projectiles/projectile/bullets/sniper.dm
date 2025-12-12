// .50 BMG (Sniper)

/obj/projectile/bullet/p50
	name =".50 BMG bullet"
	speed = 0.4
	range = 400 // Enough to travel from one corner of the Z to the opposite corner and then some.
	damage = 70
	paralyze = 100
	dismemberment = 50
	catastropic_dismemberment = TRUE
	armour_penetration = 75
	armour_ignorance = 5
	///Determines object damage.
	var/object_damage = 80
	///Determines how much additional damage the round does to mechs.
	var/mecha_damage = 10

/obj/projectile/bullet/p50/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isobj(target) && (blocked != 100))
		var/obj/thing_to_break = target
		var/damage_to_deal = object_damage
		if(ismecha(thing_to_break) && mecha_damage)
			damage_to_deal += mecha_damage
		if(damage_to_deal)
			thing_to_break.take_damage(damage_to_deal, BRUTE, BULLET, FALSE)
	return ..()

/obj/projectile/bullet/p50/surplus
	name =".50 BMG surplus bullet"
	armour_penetration = 0
	paralyze = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE

/obj/projectile/bullet/p50/disruptor
	name =".50 BMG disruptor bullet"
	damage_type = STAMINA
	paralyze = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	object_damage = 0
	mecha_damage = 100
	var/emp_radius = 2

/obj/projectile/bullet/p50/disruptor/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if((blocked != 100) && isliving(target))
		var/mob/living/living_guy = target
		living_guy.Sleeping(40 SECONDS) //Yes, its really 40 seconds of sleep, I hope you had your morning coffee.
	if(issilicon(target)) //also especially good against borgs
		var/mob/living/silicon/borg_boy = target
		borg_boy.apply_damage(damage, BRUTE)
	empulse(target, emp_radius, emp_radius)

/obj/projectile/bullet/p50/incendiary
	name =".50 BMG incendiary bullet"
	damage_type = BURN
	paralyze = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	object_damage = 30
	mecha_damage = 0

/obj/projectile/bullet/p50/incendiary/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/poor_burning_dork = target
		poor_burning_dork.adjust_fire_stacks(20)
		poor_burning_dork.ignite_mob()
	for(var/turf/nearby_turf as anything in RANGE_TURFS(2, target))
		new /obj/effect/hotspot(nearby_turf)

/obj/projectile/bullet/p50/penetrator
	name = ".50 BMG penetrator round"
	icon_state = "gauss"
	damage = 60
	range = 50
	armour_ignorance = 15
	projectile_piercing = PASSMOB|PASSVEHICLE
	projectile_phasing = ~(PASSMOB|PASSVEHICLE)
	phasing_ignore_direct_target = TRUE
	dismemberment = 0 //It goes through you cleanly.
	catastropic_dismemberment = FALSE
	paralyze = 0
	object_damage = 0

/obj/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	name = ".50 BMG aggression dissuasion round"
	icon_state = "gaussstrong"
	damage = 25
	speed = 0.3
	range = 16

/obj/projectile/bullet/p50/marksman
	name = ".50 BMG marksman round"
	damage = 50
	range = 50
	paralyze = 0
	tracer_type = /obj/effect/projectile/tracer/sniper
	impact_type = /obj/effect/projectile/impact/sniper
	muzzle_type = /obj/effect/projectile/muzzle/sniper
	hitscan = TRUE
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_outer_range = 0.75
	hitscan_light_color_override = LIGHT_COLOR_DIM_YELLOW
	muzzle_flash_intensity = 5
	muzzle_flash_range = 1
	muzzle_flash_color_override = LIGHT_COLOR_DIM_YELLOW
	impact_light_intensity = 5
	impact_light_outer_range = 1
	impact_light_color_override = LIGHT_COLOR_DIM_YELLOW
	ricochets_max = 1
	ricochet_chance = 100
	ricochet_auto_aim_angle = 45
	ricochet_auto_aim_range = 15
	ricochet_incidence_leeway = 90
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE


///.60 Strela (Wylom AM rifle)

/obj/projectile/bullet/p60strela // The funny thing is, these are wild but you only get three of them a magazine
	name =".60 Strela bullet"
	icon_state = "gaussphase"
	speed = 0.4
	damage = 50
	armour_penetration = 80
	wound_bonus = 10
	bare_wound_bonus = 10
	demolition_mod = 1.8
	/// How much damage we add to things that are weak to this bullet
	var/anti_materiel_damage_addition = 30

/obj/projectile/bullet/p60strela/Initialize(mapload)
	. = ..()
	// We do 80 total damage to anything robotic, namely borgs, and robotic simplemobs
	AddElement(/datum/element/bane, target_type = /mob/living, mob_biotypes = MOB_ROBOTIC, damage_multiplier = 0, added_damage = anti_materiel_damage_addition)

/obj/projectile/bullet/p60strela/pierce/on_hit(atom/target, blocked = 0, pierce_hit)  /// If anyone is deranged enough to use it on soft targets, you may as well let them have fun
	if(isliving(target))
		// If the bullet has already gone through 3 people, stop it on this hit
		if(pierces > 3)
			projectile_piercing = NONE

			if(damage > 10) // Lets just be safe with this one
				damage -= 10
			armour_penetration -= 10

	return ..()


// 20x160mm Neville, found on the mechs only (for now...)

/obj/projectile/bullet/neville
	name ="20x160mm Neville"
	speed = 0.65
	damage = 50
	dismemberment = 25
	armour_penetration = 85 // she may be big, but its armor piercing. less damage then the .50 cal cause of it
	armour_ignorance = 5
	///Determines object damage.
	var/object_damage = 65
	///Determines how much additional damage the round does to mechs.
	var/mecha_damage = 40
	damage_walls = TRUE // big fuken boolet

/obj/projectile/bullet/neville/pierce/on_hit(atom/target, blocked = 0, pierce_hit) /// If anyone is deranged enough to use it on soft targets, you may as well let them have fun
	if(isliving(target))
		// if it goes through 3 targets, you dont need to be rewarded more.
		if(pierces > 3)
			projectile_piercing = NONE

			if(damage > 10) // it just cut through a man, lets make it do less damage to the person behind them.
				damage -= 10
			armour_penetration -= 10

	return ..()


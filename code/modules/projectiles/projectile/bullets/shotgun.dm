/obj/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	icon_state = "pellet"
	damage = 40
	sharpness = SHARP_POINTY
	wound_bonus = -5

/obj/projectile/bullet/shotgun_slug/executioner
	name = "executioner slug" // admin only, can dismember limbs
	sharpness = SHARP_EDGED
	wound_bonus = 80

/obj/projectile/bullet/shotgun_slug/pulverizer
	name = "pulverizer slug" // admin only, can crush bones
	sharpness = NONE
	wound_bonus = 80

/obj/projectile/bullet/shotgun_slug/apds
	name = "tungsten sabot-slug"
	icon_state = "gauss"
	damage = 25 //10 less than slugs.
	speed = 0.25 //sub-caliber + lighter = speed. (Smaller number = faster)
	armour_penetration = 25
	wound_bonus = -25
	ricochets_max = 2 //Unlike slugs which tend to squish on impact, these are hard enough to bounce rarely.
	ricochet_chance = 50
	ricochet_auto_aim_range = 0
	ricochet_incidence_leeway = 50
	embedding = null
	demolition_mod = 2 //High-velocity tungsten > steel doors
	projectile_piercing = PASSMOB

/obj/projectile/bullet/shotgun_slug/apds/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		// If the bullet has already gone through 2 people, stop it on this hit
		if(pierces > 2)
			projectile_piercing = NONE

			if(damage > 10) // Lets just be safe with this one
				damage -= 7
			armour_penetration -= 25

	return ..()

/obj/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	icon_state = "pellet"
	damage = 5 //10 to 5 monkestation edit
	stamina = 55
	wound_bonus = 20
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	icon_state = "pellet"
	damage = 20

/obj/projectile/bullet/incendiary/shotgun/no_trail
	name = "precision incendiary slug"
	damage = 35
	leaves_fire_trail = FALSE



/obj/projectile/bullet/pellet
	icon_state = "pellet"
	tile_dropoff = 0.45
	tile_dropoff_s = 0.25

/obj/projectile/bullet/pellet/shotgun_buckshot ///6 pellets
	name = "buckshot pellet"
	damage = 8
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -2.5 // low damage + additional dropoff will already curb wounding potential anything past point blank

/obj/projectile/bullet/pellet/shotgun_rubbershot ///6 pellets
	name = "rubber shot pellet"
	damage = 2 //monkestation edit 3 to 2
	stamina = 10
	sharpness = NONE
	embedding = null
	tile_dropoff_s = 0 //monkestation edit
	speed = 1.2
	ricochets_max = 4
	ricochet_chance = 120
	ricochet_decay_chance = 0.9
	ricochet_decay_damage = 0.8
	ricochet_auto_aim_range = 2
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 75
	/// Subtracted from the ricochet chance for each tile traveled
	var/tile_dropoff_ricochet = 4

/obj/projectile/bullet/pellet/shotgun_rubbershot/Range()
	if(ricochet_chance > 0)
		ricochet_chance -= tile_dropoff_ricochet
	. = ..()

/obj/projectile/bullet/pellet/shotgun_buckshot/magnum ///4 pellets
	name = "magnum blockshot pellet"
	damage = 12
	wound_bonus = 7

/obj/projectile/bullet/pellet/shotgun_buckshot/magnum/Initialize(mapload)
	. = ..()
	transform = transform.Scale(1.25, 1.25)


/obj/projectile/bullet/pellet/shotgun_buckshot/express ///12 pellets
	name = "express buckshot pellet"
	damage = 3
	wound_bonus = 0

/obj/projectile/bullet/pellet/shotgun_buckshot/express/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.75, 0.75)


/obj/projectile/bullet/pellet/shotgun_buckshot/flechette ///6 pellets
	name = "flechette"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "flechette"
	damage = 6
	wound_bonus = 3
	bare_wound_bonus = 14
	sharpness = SHARP_EDGED //Did you knew flechettes fly sideways into people
	weak_against_armour = TRUE // Specializes in ripping unarmored targets apart

/obj/projectile/bullet/pellet/shotgun_buckshot/flechette/Initialize(mapload)
	. = ..()
	SpinAnimation()



/obj/projectile/bullet/pellet/shotgun_improvised ///10 pellets
	tile_dropoff = 0.35 //Come on it does 6 damage don't be like that.
	damage = 6
	wound_bonus = 0
	bare_wound_bonus = 7.5

/obj/projectile/bullet/pellet/shotgun_improvised/Initialize(mapload)
	. = ..()
	range = rand(1, 8)

/obj/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()



/obj/projectile/bullet/incendiary/shotgun/dragonsbreath ///4 pellets
	name = "dragonsbreath pellet"
	damage = 5

/obj/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 100
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	range = 7
	icon_state = "spark"
	color = "#FFFF00"
	embedding = null

/obj/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	icon_state = "pellet"
	damage = 15
	paralyze = 10

/obj/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 1, explosion_cause = src)
	return BULLET_ACT_HIT

/obj/projectile/bullet/uraniumpen
	name ="uranium penetrator"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "uraniumpen"
	damage = 35
	projectile_piercing = (ALL & (~PASSMOB))

/obj/projectile/bullet/pellet/trickshot
	name = "trickshot pellet"
	damage = 6
	tile_dropoff = 0
	ricochets_max = 5
	ricochet_chance = 100
	ricochet_decay_chance = 0
	ricochet_incidence_leeway = 0
	ricochet_decay_damage = 1

/obj/projectile/bullet/pellet/shotgun_incapacitate ///20 pellets
	name = "incapacitating pellet"
	damage = 1
	stamina = 6
	tile_dropoff_s = 3 //monkestation edit spitting distance
	embedding = null

/obj/projectile/bullet/pellet/shotgun_buckshot/beehive ///4 pellets
	name = "hornet flechette"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "hornet"
	damage = 4
	stamina = 7.5
	wound_bonus = -5
	bare_wound_bonus = 5
	wound_falloff_tile = 0
	sharpness = NONE
	ricochets_max = 5
	ricochet_chance = 200
	ricochet_auto_aim_angle = 60
	ricochet_auto_aim_range = 8
	ricochet_decay_damage = 1
	ricochet_decay_chance = 1
	ricochet_incidence_leeway = 0 //nanomachines son

/obj/projectile/bullet/pellet/shotgun_buckshot/antitide ///8 pellets
	name = "electrode"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "stardust"
	damage = 2
	stamina = 3.5
	wound_bonus = 0
	bare_wound_bonus = 0
	stutter = 3 SECONDS
	jitter = 5 SECONDS
	eyeblur = 1 SECONDS
	sharpness = NONE
	range = 7
	embedding = list(embed_chance=75, pain_chance=50, fall_chance=15, jostle_chance=80, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.9, pain_mult=2, rip_time=10)

/obj/projectile/bullet/pellet/shotgun_buckshot/antitide/on_range()
	do_sparks(1, TRUE, src)
	..()


/obj/projectile/bullet/honkshot
	name = "confetti"
	damage = 0
	sharpness = NONE
	shrapnel_type = NONE
	impact_effect_type = null
	ricochet_chance = 0
	jitter = 1 SECONDS
	eyeblur = 1 SECONDS
	hitsound = SFX_CLOWN_STEP
	range = 4
	icon_state = "guardian"

/obj/projectile/bullet/honkshot/Initialize(mapload)
	. = ..()
	SpinAnimation()
	range = rand(1, 4)
	color = pick(
		COLOR_PRIDE_RED,
		COLOR_PRIDE_ORANGE,
		COLOR_PRIDE_YELLOW,
		COLOR_PRIDE_GREEN,
		COLOR_PRIDE_BLUE,
		COLOR_PRIDE_PURPLE,
	)

// This proc addition will spawn a decal on each tile the projectile travels over
/obj/projectile/bullet/honkshot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	new /obj/effect/decal/cleanable/confetti(get_turf(old_loc))
	return ..()

// This proc addition will make living humanoids do a flip animation when hit by the projectile
/obj/projectile/bullet/honkshot/on_hit(atom/target, blocked, pierce_hit)
	if(!isliving(target))
		return ..()
	target.SpinAnimation(7,1)
	return ..()

// This proc addition adds a spark effect when the projectile expires/hits
/obj/projectile/bullet/honkshot/on_range()
	do_sparks(1, TRUE, src)
	return ..()



///Mining shotgun ammo

/obj/projectile/bullet/shotgun_slug/hunter
	name = "12g hunter slug"
	damage = 20
	range = 12
	/// How much the damage is multiplied by when we hit a mob with the correct biotype
	var/biotype_damage_multiplier = 5
	/// What biotype we look for
	var/biotype_we_look_for = MOB_BEAST

/obj/projectile/bullet/shotgun_slug/hunter/on_hit(atom/target, blocked, pierce_hit)
	if(ismineralturf(target))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(firer, FALSE)
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE
		return ..()
	if(!isliving(target) || (damage > initial(damage)))
		return ..()
	var/mob/living/target_mob = target
	if(target_mob.mob_biotypes & biotype_we_look_for || istype(target_mob, /mob/living/simple_animal/hostile/megafauna))
		damage *= biotype_damage_multiplier
	return ..()

/obj/projectile/bullet/shotgun_slug/hunter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, mob_biotypes = MOB_BEAST, damage_multiplier = 5)



/obj/projectile/bullet/pellet/beeshot
	name ="beeshot"
	damage = 6
	ricochets_max = 0
	ricochet_chance = 0
	var/spawner_type = /mob/living/basic/bee/toxin
	var/deliveryamt = 1

/obj/projectile/bullet/pellet/beeshot/on_hit(atom/target, blocked = 0, pierce_hit)			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	. = ..()
	if(!.)
		return
	if(spawner_type && deliveryamt)
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		var/list/spawned = spawn_and_random_walk(spawner_type, T, deliveryamt, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))
		afterspawn(spawned)

	qdel(src)

/obj/projectile/bullet/pellet/beeshot/proc/afterspawn(list/mob/spawned)
	return


// Mech Scattershot

/obj/projectile/bullet/scattershot
	icon_state = "pellet"
	damage = 24


//Breaching Ammo

/obj/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy airlocks and windows with only a few shots. Ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 5 //does shit damage to everything except doors and windows
	demolition_mod = 200 //one shot to break a window or grille, or two shots to breach an airlock door


//Admeme shotgun

/obj/projectile/bullet/pellet/shotgun_death
	name = "buckshot pellet"
	damage = 25
	wound_bonus = 10
	bare_wound_bonus = 10

	ricochets_max = 6
	ricochet_chance = 240
	ricochet_decay_chance = 0.9
	ricochet_decay_damage = 0.8
	ricochet_auto_aim_range = 2
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 75


///Mining shotgun, 5 pellet

/obj/projectile/bullet/hydrakinetic
	name = "Kinetic Hydra Sabot"
	icon_state = "bullet"
	damage = 7
	armour_penetration = -15
	fauna_mod = 2

/obj/projectile/bullet/hydrakinetic/on_hit(atom/target, Firer, blocked = 0, pierce_hit) //its not meant to tear through walls like a plasma cutter, but will still at least bust down a wall if it hits one.
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)
	. = ..()


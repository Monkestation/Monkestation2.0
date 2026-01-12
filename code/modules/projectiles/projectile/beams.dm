/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 22
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_system = OVERLAY_LIGHT
	light_outer_range = 1
	light_power = 1
	light_color = COLOR_SOFT_RED
	ricochets_max = 50 //Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL
	wound_bonus = -20
	bare_wound_bonus = 10


/obj/projectile/beam/laser
	generic_name = "laser beam"
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	wound_bonus = -30
	bare_wound_bonus = 40

/obj/projectile/beam/laser/lasrifle
	generic_name = "rifle beam"
	damage = 25
	range = 30
	tracer_type = /obj/effect/projectile/tracer/laser/rifle
	impact_type = /obj/effect/projectile/impact/laser/rifle
	muzzle_type = /obj/effect/projectile/muzzle/laser/rifle
	hitscan = TRUE
	tile_dropoff = 1 //This makes ricochets less impactful
	armour_penetration = -30 //armor is * 130% more effective against it
	wound_bonus = -15
	wound_falloff_tile = 3
	impact_effect_type = null
	hitscan_light_intensity = 2
	hitscan_light_outer_range = 0.5
	hitscan_light_color_override = LIGHT_COLOR_INTENSE_RED
	muzzle_flash_intensity = 4
	muzzle_flash_range = 0.5
	muzzle_flash_color_override = LIGHT_COLOR_INTENSE_RED
	impact_light_intensity = 4
	impact_light_outer_range = 1
	impact_light_color_override = LIGHT_COLOR_INTENSE_RED
	expanded_bounce = TRUE
	ricochets_max = 2
	ricochet_chance = 100
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 10
	ricochet_incidence_leeway = 90
	ricochet_shoots_firer = TRUE

/obj/projectile/beam/laser/carbine
	icon_state = "carbine_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	damage = 9

//overclocked laser, does a bit more damage but has much higher wound power (-0 vs -20)
/obj/projectile/beam/laser/hellfire
	name = "hellfire laser"
	wound_bonus = 0
	damage = 25
	speed = 0.6 // higher power = faster, that's how light works right

/obj/projectile/beam/laser/hellfire/Initialize(mapload)
	. = ..()
	transform *= 2

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.ignite_mob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall


/obj/projectile/beam/laser/musket
	name = "low-power laser"
	icon_state = "laser_musket"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 28
	stamina = 17.5
	light_color = COLOR_STRONG_VIOLET
	weak_against_armour = TRUE

/obj/projectile/beam/laser/musket/prime
	name = "mid-power laser"
	damage = 45
	stamina = 10
	weak_against_armour = FALSE

/obj/projectile/beam/laser/musket/syndicate
	name = "resonant laser"
	damage = 30
	stamina = 32.5
	weak_against_armour = FALSE
	armour_penetration = 45 //less powerful than armor piercing rounds
	wound_bonus = 10

/obj/projectile/beam/weak
	damage = 15

/obj/projectile/beam/weak/penetrator
	armour_penetration = 80

/obj/projectile/beam/practice
	name = "practice laser"
	generic_name = "practice laser beam"
	damage = 0

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 15
	range = 15
	armour_penetration = 100
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 0
	damage_type = STAMINA
	stamina = 24
	paralyze_timer = 5 SECONDS
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/disabler/weak
	stamina = 11.5

/obj/projectile/beam/disabler/smoothbore
	name = "unfocused disabler beam"
	weak_against_armour = TRUE

/obj/projectile/beam/disabler/smoothbore/prime
	name = "focused disabler beam"
	weak_against_armour = FALSE
	stamina = 30

/obj/projectile/beam/pulse
	name = "pulse"
	generic_name = "pulse beam"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	wound_bonus = 10

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || isstructure(target)))
		if(isobj(target))
			SSexplosions.low_mov_atom += target //monkestation edit
		else
			SSexplosions.lowturf += target //monkestation edit

/obj/projectile/beam/pulse/shotgun
	damage = 30

/obj/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	damage = 100 //monkestation addition
	projectile_piercing = ALL
	var/pierce_hits = 2

/obj/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = 0, pierce_hit)
	if(pierce_hits <= 0)
		projectile_piercing = NONE
	pierce_hits -= 1
	return ..()

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	wound_bonus = -40
	bare_wound_bonus = 70

/obj/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/projectile/beam/emitter/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_outer_range = 0.75
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_outer_range = 2.5
	impact_light_color_override = COLOR_LIME
	range = 255 //come on, have some fun now! monkestation edit

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.stamina.adjust(-17)

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/projectile/magic/shrink/alien
	antimagic_flags = NONE
	shrink_time = 9 SECONDS

/obj/projectile/beam/laser/plasma_glob
	name = "plasma globule"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "plasma_glob"
	damage = 10
	speed = 1.5
	bare_wound_bonus = 55 // Lasers have a wound bonus of 40, this is a bit higher
	wound_bonus = -50 // However we do not very much against armor
	pass_flags = PASSTABLE | PASSGRILLE // His ass does NOT pass through glass!
	weak_against_armour = TRUE


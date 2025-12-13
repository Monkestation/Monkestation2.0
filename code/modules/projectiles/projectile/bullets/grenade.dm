// 40mm (Grenade Launcher/China Lake)

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 60
	embedding = null
	shrapnel_type = null
	range = 30

/obj/projectile/bullet/a40mm/Range() //because you lob the grenade to achieve the range :)
	if(!has_gravity(get_area(src)))
		range++
	return ..()

/obj/projectile/bullet/a40mm/proc/payload(atom/target)
	explosion(target, devastation_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 2, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	payload(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a40mm/on_range()
	payload(get_turf(src))
	return ..()

/obj/projectile/bullet/a40mm/proc/valid_turf(turf1, turf2)
	for(var/turf/line_turf in get_line(turf1, turf2))
		if(line_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
			return FALSE
	return TRUE

//40mm slug-grenade
/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "40mm rubber slug"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER_projectile"
	damage = 20
	stamina = 125 //BONK
	paralyze = 5 SECONDS
	wound_bonus = 30
	weak_against_armour = TRUE

//40mm weak HE grenade, printable at an autolath
/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	damage = 30

/obj/projectile/bullet/a40mm/weak/payload(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

//40mm incendiary grenade
/obj/projectile/bullet/a40mm/incendiary
	name ="40mm incendiary grenade"
	damage = 15

/obj/projectile/bullet/a40mm/incendiary/payload(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/extra_crispy_carbon = target
		extra_crispy_carbon.adjust_fire_stacks(20)
		extra_crispy_carbon.ignite_mob()
		extra_crispy_carbon.apply_damage(30, BURN)

	var/turf/our_turf = get_turf(src)

	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			var/obj/effect/hotspot/fire_tile = locate(nearby_turf) || new(nearby_turf)
			fire_tile.temperature = CELCIUS_TO_KELVIN(800 CELCIUS)
			nearby_turf.hotspot_expose(CELCIUS_TO_KELVIN(800 CELCIUS), 125, 1)
			for(var/mob/living/crispy_living in nearby_turf.contents)
				crispy_living.apply_damage(30, BURN)
				if(iscarbon(crispy_living))
					var/mob/living/carbon/crispy_carbon = crispy_living
					crispy_carbon.adjust_fire_stacks(10)
					crispy_carbon.ignite_mob()

	explosion(target, flame_range = 1, flash_range = 3, adminlog = FALSE, explosion_cause = src)

//40mm smoke grenade
/obj/projectile/bullet/a40mm/smoke
	name ="40mm smoke grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/smoke/payload(atom/target)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(4, holder = src, location = src)
	smoke.start()

//40mm flashbang grenade
/obj/projectile/bullet/a40mm/stun
	name ="40mm stun grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/stun/payload(atom/target)
	playsound(src, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)

	explosion(target, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	do_sparks(rand(5, 9), FALSE, src)

	var/turf/our_turf = get_turf(src)

	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			if(prob(50))
				do_sparks(rand(1, 9), FALSE, nearby_turf)
			for(var/mob/living/stunned_living in nearby_turf.contents)
				stunned_living.Paralyze(5 SECONDS)
				stunned_living.Knockdown(8 SECONDS)
				stunned_living.soundbang_act(1, 200, 10, 15)

//40mm HEDP grenade, good vs mechs
/obj/projectile/bullet/a40mm/hedp
	name ="40mm HEDP grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmHEDP_projectile"
	damage = 50
	var/anti_material_damage_bonus = 75

/obj/projectile/bullet/a40mm/hedp/payload(atom/target)
	explosion(target, heavy_impact_range = 0, light_impact_range = 2,  flash_range = 1, adminlog = FALSE, explosion_cause = src)

	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/mecha = target
		mecha.take_damage(anti_material_damage_bonus)
	if(issilicon(target))
		var/mob/living/silicon/borgo = target
		borgo.gib()

	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(isclosedturf(target)) //walls get blasted
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)

//40mm fragmentation grenade
/obj/projectile/bullet/a40mm/frag
	name ="40mm fragmentation grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"

/obj/projectile/bullet/a40mm/frag/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/a40mm_frag(drop_location())

	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

/obj/item/grenade/a40mm_frag
	name = "40mm fragmentation payload"
	desc = "An anti-personnel fragmentation payload. How the heck did this get here?"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	shrapnel_type = /obj/projectile/bullet/shrapnel/a40mm_frag
	shrapnel_radius = 4
	det_time = 0
	display_timer = FALSE
	ex_light = 2

/obj/projectile/bullet/shrapnel/a40mm_frag
	name = "flying shrapnel hunk"
	range = 4
	dismemberment = 15
	ricochets_max = 6
	ricochet_chance = 75
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9


#define GRENADE_SMOKE_RANGE 0.75

//.980 riot grenades

/obj/projectile/bullet/c980grenade
	name = ".980 Tydhouer practice grenade"
	damage = 20
	stamina = 15
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


#undef GRENADE_SMOKE_RANGE


/// 40mm "kinetic" grenades, I.E mining grenades

/obj/projectile/bullet/a40mm/kinetic
	name ="40mm kinetic grenade"
	desc = "OH SHIT!!!"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bolter"
	damage = 50
	range = 25
	fauna_mod = 2

/obj/projectile/bullet/a40mm/kinetic/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/kineticshrapnel(drop_location())
	shrapnel_maker.detonate()
	qdel(shrapnel_maker)
	explosion(target, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 4, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)


/obj/item/grenade/kineticshrapnel
	name = "Kinetic fragmentation payload"
	desc = "holy fucking shit you should NOT be seeing this please report it and then CRY ABOUT IT"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	shrapnel_type = /obj/projectile/bullet/shrapnel/kinetic
	shrapnel_radius = 2
	det_time = 0
	display_timer = FALSE
	ex_light = 0

/obj/projectile/bullet/shrapnel/kinetic
	name = "Kinetic Shrapnel Hunk"
	range = 5
	damage = 25
	weak_against_armour = TRUE
	dismemberment = 0
	ricochets_max = 0
	ricochet_chance = 0
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0
	fauna_mod = 3

/obj/projectile/bullet/shrapnel/kinetic/on_hit(atom/target, Firer, blocked = 0, pierce_hit) //its not meant to tear through walls like a plasma cutter, but will still at least bust down a wall if it hits one.
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)
	. = ..()

/obj/item/grenade/kineticshrapnel/detonate(mob/living/lanced_by)

	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)


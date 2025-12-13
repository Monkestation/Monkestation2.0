
//PKA projectile
/obj/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	damage_type = BRUTE
	armor_flag = BOMB
	range = 3
	log_override = TRUE

	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 0.25
	var/obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun
	var/Skillbasedweapon = TRUE //monkestation edit that allows you to toggle off the quicker reload chance on hitting minerals

/obj/projectile/kinetic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parriable_projectile, parry_callback = CALLBACK(src, PROC_REF(on_parry)))

/obj/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/projectile/kinetic/prehit_pierce(atom/target)
	. = ..()
	if(. == PROJECTILE_PIERCE_PHASE)
		return
	if(kinetic_gun)
		var/list/mods = kinetic_gun.modkits
		for(var/obj/item/borg/upgrade/modkit/modkit in mods)
			modkit.projectile_prehit(src, target, kinetic_gun)
	if(!pressure_decrease_active && !lavaland_equipment_pressure_check(get_turf(target)))
		name = "weakened [name]"
		damage = damage * pressure_decrease
		pressure_decrease_active = TRUE

/obj/projectile/kinetic/proc/on_parry(mob/user)
	SIGNAL_HANDLER

	// Ensure that if the user doesn't have tracer mod we're still visible
	icon_state = "ka_tracer"
	update_appearance()

/obj/projectile/kinetic/on_range()
	strike_thing()
	..()

/obj/projectile/kinetic/on_hit(atom/target, blocked = 0, pierce_hit)
	strike_thing(target)
	. = ..()

/obj/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) //hopefully whoever shot this was not very, very unfortunate.
		var/list/mods = kinetic_gun.modkits
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer, TRUE)
		if(iscarbon(firer))
			var/mob/living/carbon/carbon_firer = firer
			var/skill_modifier = 1
			// If there is a mind, check for skill modifier to allow them to reload faster.
			if(carbon_firer.mind)
				skill_modifier = carbon_firer.mind.get_skill_modifier(/datum/skill/mining, SKILL_SPEED_MODIFIER)
			if(Skillbasedweapon) //Monkestation edit that allows toggling off this feature, for special mining weapons like the PKSMG
				kinetic_gun.attempt_reload(kinetic_gun.recharge_time * skill_modifier) //If you hit a mineral, you might get a quicker reload. epic gamer style.
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color

//mecha_kineticgun version of the projectile
/obj/projectile/kinetic/mech
	range = 5

//smg version
/obj/projectile/kinetic/smg
	name = "kinetic projectile"
	damage = 10
	range = 7
	icon_state = "bullet"
	Skillbasedweapon = FALSE

/obj/item/ammo_casing/energy/kinetic/smg ///magazine-based gun, 45 rounds
	projectile_type = /obj/projectile/kinetic/smg
	select_name = "kinetic"
	e_cost = 0 // Can't use the macro
	fire_sound = 'sound/weapons/kenetic_accel.ogg'


/obj/item/ammo_casing/energy/kinetic/glock
	projectile_type = /obj/projectile/kinetic/glock

/obj/projectile/kinetic/glock
	name = "light kinetic force"
	damage = 10


/obj/item/ammo_casing/energy/kinetic/railgun
	projectile_type = /obj/projectile/kinetic/railgun
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/projectile/kinetic/railgun
	name = "hyper kinetic force"
	damage = 100
	range = 7
	pressure_decrease = 0.10 // Pressured enviorments are a no go for the railgun
	speed = 0.1 // NYOOM
	projectile_piercing = PASSMOB


/obj/item/ammo_casing/energy/kinetic/repeater
	projectile_type = /obj/projectile/kinetic/repeater
	e_cost = LASER_SHOTS(3, STANDARD_CELL_CHARGE * 0.5)

/obj/projectile/kinetic/repeater
	name = "rapid kinetic force"
	damage = 20
	range = 4


/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/projectile/kinetic/shockwave
	fire_sound = 'sound/weapons/gun/general/cannon.ogg'

/obj/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	damage = 40
	range = 2


/obj/item/ammo_casing/energy/kinetic/meme
	projectile_type = /obj/projectile/kinetic/meme
	e_cost = 0  // Can't use the macro
	pellets = 69
	variance = 90
	fire_sound = 'sound/effects/adminhelp.ogg'

/obj/projectile/kinetic/meme
	name = "proto kinetic meme force"
	damage = 420
	range = 300
	pressure_decrease = 1
	dismemberment = 10
	catastropic_dismemberment = TRUE
	hitsound = 'sound/effects/adminhelp.ogg'


/obj/item/ammo_casing/energy/kinetic/meme/nonlethal
	projectile_type = /obj/projectile/kinetic/meme/nonlethal

/obj/projectile/kinetic/meme/nonlethal
	name = "surprisingly soft proto kinetic meme force"
	damage = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	stun = 69
	knockdown = 69
	paralyze = 69
	immobilize = 69
	unconscious = 69
	eyeblur = 69
	drowsy = 69 SECONDS
	jitter = 69 SECONDS
	stamina = 69
	stutter = 69 SECONDS
	slur = 69 SECONDS


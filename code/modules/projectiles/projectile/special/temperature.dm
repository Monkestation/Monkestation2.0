/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	/// What temp to trend the target towards
	var/temperature = -60
	var/min = 200
	var/max = 400
	/// How much temp per shot to apply
	var/temperature_mod_per_shot = 0.8

/obj/projectile/temp/is_hostile_projectile()
	return BODYTEMP_NORMAL - temperature != 0 // our damage is done by cooling or heating (casting to boolean here)

/obj/projectile/temp/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))

		var/mob/living/M = target
		M.adjust_bodytemperature(temperature_mod_per_shot * ((100-blocked) / 100) * (temperature), min, max, use_insulation = TRUE)

/obj/projectile/temp/hot
	name = "heat beam"
	temperature =  60

/obj/projectile/temp/cryo
	name = "cryo beam"
	range = 3
	temperature = -60
	min = 150
	temperature_mod_per_shot = 2.5 // get this guy really chilly really fast

/obj/projectile/temp/cryo/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(isopenturf(target))
		var/turf/open/T = target
		T.freeze_turf()

/obj/projectile/temp/cryo/on_range()
	var/turf/T = get_turf(src)
	if(isopenturf(T))
		var/turf/open/O = T
		O.freeze_turf()
	return ..()

/obj/projectile/temp/pyro
	name = "hot beam"
	icon_state = "firebeam" // sets on fire, diff sprite!
	range = 9
	temperature = 240
	max = 1000

/obj/projectile/temp/pyro/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!.)
		return
	var/mob/living/living_target = target
	if(!istype(living_target))
		return
	living_target.adjust_fire_stacks(2)
	living_target.ignite_mob()

/obj/projectile/temp/pyro/on_range()
	var/turf/location = get_turf(src)
	new /obj/effect/hotspot(location)
	location.hotspot_expose(700, 50, 1)

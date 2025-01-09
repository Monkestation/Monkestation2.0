/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	/// What temp to trend the target towards
	var/temperature = -(10 CELCIUS) //monkestation edit
	/// How much temp per shot to apply
	var/temperature_mod_per_shot = 1 //monkestation edit 0.25 to 1

/obj/projectile/temp/is_hostile_projectile()
	return BODYTEMP_NORMAL - temperature != 0 // our damage is done by cooling or heating (casting to boolean here)

/obj/projectile/temp/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(temperature_mod_per_shot * ((100-blocked) / 100) * temperature, use_insulation = TRUE) //monkestation edit

/obj/projectile/temp/hot
	name = "heat beam"
	temperature = 10 CELCIUS //monkestation edit

/obj/projectile/temp/cryo
	name = "cryo beam"
	//range = 3 //monkestation removal
	temperature_mod_per_shot = 2 // get this guy really chilly really fast //monkestation edit
	can_hit_turfs = TRUE //monkestation edit

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


//jeep, basically

/obj/vehicle/ridden/argonaut
	name = "UV-05a Argonaut"
	desc = "A stripped down Light Utility Vehicle, perfect for hit and run tactics."
	icon = 'icons/obj/car.dmi'
	icon_state = "argonaut"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 4
	max_occupants = 4
	pass_flags_self = null
	max_integrity = 200
	armor_type = /datum/armor/argonaut
	var/crash_all = FALSE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	cover_amount = 50


/datum/armor/argonaut
	melee = 25
	bullet = 10
	laser = 15
	energy = 15
	fire = 20
	acid = 30

/obj/vehicle/ridden/argonaut/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "argonaut_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/argonaut)

/obj/vehicle/ridden/argonaut/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return

	if(crash_all)
		if(ismovable(A))
			var/atom/movable/AM = A
			AM.throw_at(get_edge_target_turf(A, dir), 1, 1)
		visible_message(span_danger("[src] crashes into [A]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.Paralyze(30)
	rammed.stamina.adjust(-30)
	rammed.apply_damage(rand(10,25), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(A, dir), 1, 1)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/argonaut/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)

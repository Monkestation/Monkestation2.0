
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
	integrity_failure = 0.2

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
	rammed.apply_damage(rand(10,18), BRUTE)
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


/obj/vehicle/ridden/argonaut/welder_act(mob/living/user, obj/item/W)
	if((user.istate & ISTATE_HARM))
		return
	. = TRUE
	if(DOING_INTERACTION(user, src))
		balloon_alert(user, "you're already repairing it!")
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it's not damaged!")
		return
	if(!W.tool_start_check(user, amount=1))
		return
	user.balloon_alert_to_viewers("started welding [src]", "started repairing [src]")
	audible_message(span_hear("You hear welding."))
	var/did_the_thing
	while(atom_integrity < max_integrity)
		if(W.use_tool(src, user, 2.5 SECONDS, volume=50, amount=1))
			did_the_thing = TRUE
			atom_integrity += min(10, (max_integrity - atom_integrity))
			audible_message(span_hear("You hear welding."))
		else
			break
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(atom_integrity >= max_integrity) ? "fully" : "partially"] repaired [src]")
	else
		user.balloon_alert_to_viewers("stopped welding [src]", "interrupted the repair!")


/obj/vehicle/ridden/argonaut/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/argonaut/process(seconds_per_tick)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = src)
	smoke.start()

/obj/vehicle/ridden/argonaut/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/argonaut/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()



//jeep, basically, but armored / enclosed!

/obj/vehicle/ridden/odyssey
	name = "UV-05c Odyssey"
	desc = "A modfication to an argonaut, providing cover from small arms and weather."
	icon = 'icons/obj/car.dmi'
	icon_state = "odyssey"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 2
	max_occupants = 2
	pass_flags_self = null
	max_integrity = 250
	armor_type = /datum/armor/odyssey
	var/crash_all = FALSE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	cover_amount = 95
	integrity_failure = 0.2

/datum/armor/odyssey
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	fire = 20
	acid = 30

/obj/vehicle/ridden/odyssey/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "odyssey_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/odyssey)

/obj/vehicle/ridden/odyssey/Bump(atom/A)
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
	rammed.apply_damage(rand(10,18), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(A, dir), 1, 1)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/odyssey/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)


/obj/vehicle/ridden/odyssey/welder_act(mob/living/user, obj/item/W)
	if((user.istate & ISTATE_HARM))
		return
	. = TRUE
	if(DOING_INTERACTION(user, src))
		balloon_alert(user, "you're already repairing it!")
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it's not damaged!")
		return
	if(!W.tool_start_check(user, amount=1))
		return
	user.balloon_alert_to_viewers("started welding [src]", "started repairing [src]")
	audible_message(span_hear("You hear welding."))
	var/did_the_thing
	while(atom_integrity < max_integrity)
		if(W.use_tool(src, user, 2.5 SECONDS, volume=50, amount=1))
			did_the_thing = TRUE
			atom_integrity += min(10, (max_integrity - atom_integrity))
			audible_message(span_hear("You hear welding."))
		else
			break
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(atom_integrity >= max_integrity) ? "fully" : "partially"] repaired [src]")
	else
		user.balloon_alert_to_viewers("stopped welding [src]", "interrupted the repair!")


/obj/vehicle/ridden/odyssey/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/odyssey/process(seconds_per_tick)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = src)
	smoke.start()

/obj/vehicle/ridden/odyssey/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/odyssey/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

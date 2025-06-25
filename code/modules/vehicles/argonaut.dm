
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
	cover_amount = 35
	integrity_failure = 0.2
	var/crash_dmg_high = 20
	var/crash_dmg_low = 10
	var/crash_dmg_stm = 50
	var/crash_para_driv = 1.5
	var/crash_para_pass = 0.3
	var/crash_para_roadkill = 0.9

/datum/armor/argonaut
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	fire = 30
	acid = 30

/obj/vehicle/ridden/argonaut/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "argonaut_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/argonaut)

/obj/vehicle/ridden/argonaut/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return
	var/mob/living/rider = buckled_mobs[1]
	var/mob/living/pass1 = buckled_mobs[2]
	var/mob/living/pass2 = buckled_mobs[3]
	var/mob/living/pass3 = buckled_mobs[4]
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.stamina.adjust(-crash_dmg_stm)
	rammed.apply_damage(rand(crash_dmg_low,crash_dmg_high), BRUTE)
	rider.Paralyze(crash_para_driv SECONDS)
	pass1.Paralyze(crash_para_pass SECONDS)
	pass2.Paralyze(crash_para_pass SECONDS)
	pass3.Paralyze(crash_para_pass SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
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
		if(W.use_tool(src, user, 1.3 SECONDS, volume=50, amount=1))
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
	desc = "A modfication to an argonaut, providing cover from small arms."
	icon = 'icons/obj/car.dmi'
	icon_state = "odyssey"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 2
	max_occupants = 2
	pass_flags_self = null
	max_integrity = 250
	armor_type = /datum/armor/argonaut
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	cover_amount = 85
	integrity_failure = 0.2
	var/crash_dmg_high = 20
	var/crash_dmg_low = 10
	var/crash_dmg_stm = 50
	var/crash_para_driv = 1.5
	var/crash_para_pass = 0.3
	var/crash_para_roadkill = 0.9

/obj/vehicle/ridden/odyssey/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "odyssey_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/odyssey)


/obj/vehicle/ridden/odyssey/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return
	var/mob/living/rider = buckled_mobs[1]
	var/mob/living/pass1 = buckled_mobs[2]
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.stamina.adjust(-crash_dmg_stm)
	rammed.apply_damage(rand(crash_dmg_low,crash_dmg_high), BRUTE)
	rider.Paralyze(crash_para_driv SECONDS)
	pass1.Paralyze(crash_para_pass SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
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
		if(W.use_tool(src, user, 1.5 SECONDS, volume=50, amount=1))
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

/obj/item/argonaut_control
	name = "Argonaut's controls"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | NOBLUDGEON | DROPDEL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/obj/vehicle/ridden/argonaut/jeep


/obj/item/argonaut_control/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	jeep = loc
	if(!istype(jeep))
		return INITIALIZE_HINT_QDEL

/obj/item/odyssey_control
	name = "Odyssey's controls"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | NOBLUDGEON | DROPDEL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/obj/vehicle/ridden/odyssey/jeepers


/obj/item/odyssey_control/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	jeepers = loc
	if(!istype(jeepers))
		return INITIALIZE_HINT_QDEL

/obj/vehicle/ridden/argonaut/corporate
	name = "UV-05a Argonaut NT edition"
	desc = "An argonaut downrated for station side use, anti-vehicular manslaughter components have been added to dissuade lawsuits."
	icon_state = "argonautnt"
	crash_para_driv = 3

/obj/vehicle/ridden/argonaut/corporate/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "argonautnt_cover", ABOVE_MOB_LAYER))

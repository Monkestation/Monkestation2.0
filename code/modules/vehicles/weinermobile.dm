
//jeep, basically

/obj/vehicle/ridden/wienermobile
	name = "Wiener Wurstchen Mobile"
	desc = "A bus that has been themed to look like a hotdog, its absolute Peak."
	icon = 'icons/obj/car.dmi'
	icon_state = "wienermobile"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 9
	max_occupants = 9
	pass_flags_self = null
	max_integrity = 400
	cover_amount = 45
	armor_type = /datum/armor/weeweenor
	var/crash_all = FALSE
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	integrity_failure = 0.2
	var/crash_dmg_stm = 5
	var/crash_para_driv = 2
	var/crash_para_pass = 0.5
	var/crash_para_roadkill = 0.5

/datum/armor/weeweenor
	melee = 20
	bullet = 10
	laser = 10
	energy = 10
	fire = 30
	acid = 30

/obj/vehicle/ridden/wienermobile/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "wienermobile_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wienermobile)

/obj/vehicle/ridden/wienermobile/Bump(mob/living/carbon/human/rammed)
	. = ..()
	if(!ishuman(rammed) || !rammed.density || !has_buckled_mobs())
		return
	rammed.stamina?.adjust(-crash_dmg_stm)
	for(var/mob/living/rider in buckled_mobs)
		var/paralyze_time = is_driver(rider) ? crash_para_driv : crash_para_pass
		rider.Paralyze(paralyze_time SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
	visible_message(span_danger("[src] crashes into [rammed]!"))
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/wienermobile/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)

/obj/vehicle/ridden/wienermobile/welder_act(mob/living/user, obj/item/W)
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


/obj/vehicle/ridden/wienermobile/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/wienermobile/process(seconds_per_tick)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = src)
	smoke.start()

/obj/vehicle/ridden/wienermobile/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/wienermobile/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

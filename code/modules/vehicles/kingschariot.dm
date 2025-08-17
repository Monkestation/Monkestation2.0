
//jeep, basically

/obj/vehicle/ridden/kingschariot
	name = "The Kings Chariot"
	desc = "It is foretold that it cannot be stopped, we beg you to try."
	icon = 'icons/obj/car.dmi'
	icon_state = "kingschariot"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 2
	max_occupants = 2
	pass_flags_self = null
	max_integrity = 400
	cover_amount = 60
	armor_type = /datum/armor/bergen
	var/crash_all = FALSE
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	integrity_failure = 0.2
	var/crash_dmg_min = 30
	var/crash_dmg_stm = 70
	var/crash_para_driv = 0.7
	var/crash_para_pass = 0.5
	var/crash_para_roadkill = 0.5
	var/crash_dmg_max = 50
/datum/armor/bergen
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	fire = 30
	acid = 30

/obj/vehicle/ridden/kingschariot/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "kingschariot_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/kingschariot)

/obj/vehicle/ridden/kingschariot/Bump(mob/living/carbon/human/rammed)
	. = ..()
	if(!ishuman(rammed) || !rammed.density || !has_buckled_mobs())
		return
	rammed.stamina?.adjust(-crash_dmg_stm)
	for(var/mob/living/rider in buckled_mobs)
		var/paralyze_time = is_driver(rider) ? crash_para_driv : crash_para_pass
		rider.Paralyze(paralyze_time SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
	rammed.apply_damage(rand(crash_dmg_min,crash_dmg_max), BRUTE)
	visible_message(span_danger("[src] crashes into [rammed]!"))
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/kingschariot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)

/obj/vehicle/ridden/kingschariot/welder_act(mob/living/user, obj/item/W)
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


/obj/vehicle/ridden/kingschariot/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/kingschariot/process(seconds_per_tick)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = src)
	smoke.start()

/obj/vehicle/ridden/kingschariot/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/kingschariot/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()


//jeep, basically

/obj/vehicle/ridden/hoverdog
	name = "XXL-9a 'Hoverdog'"
	desc = "A top of the line hoverbike, comissioned by Nanotrassen for their hotdog salespeople."
	icon = 'icons/obj/car.dmi'
	icon_state = "hoverdog"
	layer = LYING_MOB_LAYER
	pixel_y = -48
	pixel_x = -48
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = null
	max_integrity = 200
	cover_amount = 45
	armor_type = /datum/armor/weeweenor
	var/crash_all = FALSE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	key_type = /obj/item/key/hoverdog
	integrity_failure = 0.2
	var/crash_dmg_high = 0
	var/crash_dmg_low = 0
	var/crash_dmg_stm = 25
	var/crash_para_driv = 1.2
	var/crash_para_pass = 0.3
	var/crash_para_roadkill = 0.9

/datum/armor/weeweenor
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	fire = 30
	acid = 30


/obj/vehicle/ridden/hoverdog/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "hoverdog_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/hoverdog)

/obj/vehicle/ridden/hoverdog/Bump(mob/living/carbon/human/rammed)
	. = ..()
	if(!ishuman(rammed) || !rammed.density || !has_buckled_mobs())
		return
	rammed.stamina?.adjust(-crash_dmg_stm)
	rammed.apply_damage(rand(crash_dmg_low, crash_dmg_high), BRUTE)
	for(var/mob/living/rider in buckled_mobs)
		var/paralyze_time = is_driver(rider) ? crash_para_driv : crash_para_pass
		rider.Paralyze(paralyze_time SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
	rammed.throw_at(get_edge_target_turf(rammed, dir), 1, 1)
	visible_message(span_danger("[src] crashes into [rammed]!"))
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/hoverdog/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)

/obj/vehicle/ridden/hoverdog/welder_act(mob/living/user, obj/item/W)
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


/obj/vehicle/ridden/hoverdog/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/hoverdog/process(seconds_per_tick)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = src)
	smoke.start()

/obj/vehicle/ridden/hoverdog/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/hoverdog/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

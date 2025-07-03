
/obj/vehicle/ridden/snazbike
	name = "Snaz Bike"
	desc = "A crappy tricycle made out of scrap, cables, and dreams, goes fast, breaks fast."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snazbike"
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = null
	max_integrity = 75 // dont let it get hit!
	armor_type = /datum/armor/snazbike
	var/crash_all = FALSE
	cover_amount = 35
	var/crash_dmg_high = 10
	var/crash_dmg_low = 1
	var/crash_dmg_stm = 50
	var/crash_para_driv = 1.8
	var/crash_para_roadkill = 0.5

/datum/armor/snazbike
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	fire = 30
	acid = 30

/obj/vehicle/ridden/snazbike/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "snazbike_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/snazbike)

/obj/vehicle/ridden/snazbike/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return
	var/mob/living/rider = buckled_mobs[1]
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.stamina.adjust(-crash_dmg_stm)
	rammed.apply_damage(rand(crash_dmg_low,crash_dmg_high), BRUTE)
	rider.Paralyze(crash_para_driv SECONDS)
	rammed.Paralyze(crash_para_roadkill SECONDS)
	rammed.throw_at(get_edge_target_turf(A, dir), 1, 1)
	visible_message(span_danger("[src] crashes into [rammed]!"))
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/snazbike/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)

/obj/vehicle/ridden/snazbike/welder_act(mob/living/user, obj/item/W)
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

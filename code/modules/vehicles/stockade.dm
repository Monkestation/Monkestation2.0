
//Heavy Field Gun

/obj/vehicle/ridden/stockade
	name = "Balfour Stockade"
	desc = "A 75mm Cannon used for annihalating bunkers, thin space station walls are not feet of concrete."
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "stockade"
	layer = LYING_MOB_LAYER
	pixel_y = 0
	pixel_x = -24
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = null
	max_integrity = 375
	armor_type = /datum/armor/stockade
	var/crash_all = FALSE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	cover_amount = 92 // its has a giant gunshield
	var/can_be_undeployed = TRUE
	var/undeploy_time = 3 SECONDS
	var/always_anchored = TRUE
	var/spawned_on_undeploy = /obj/machinery/deployable_turret/stockade

/datum/armor/stockade
	melee = -10
	bullet = 65
	laser = 65
	energy = 65
	bomb = -10
	fire = 10  // incendaries can cook it for balance
	acid = 10  // same with acid

/obj/vehicle/ridden/stockade/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "stockade_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/stockade)

/obj/vehicle/ridden/stockade/welder_act(mob/living/user, obj/item/W)
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

/obj/vehicle/ridden/stockade/wrench_act(mob/living/user, obj/item/wrench/used_wrench)
	. = ..()
	if(!can_be_undeployed)
		return
	if(!ishuman(user))
		return
	used_wrench.play_tool_sound(user)
	user.balloon_alert(user, "deploying...")
	if(!do_after(user, undeploy_time))
		return
	var/obj/undeployed_object = new spawned_on_undeploy(get_turf(src))
	//Keeps the health the same even if you redeploy the gun
	undeployed_object.modify_max_integrity(max_integrity)
	qdel(src)


//field artillery, not like pirate cannon, cause you can aim it.

/obj/vehicle/ridden/artillerylight
	name = "NT Model-2508 Field Cannon"
	desc = "A small field cannon based off a centuries old design, updated with modern materials to make it much lighter and safe to fire on stations."
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "artillery_light"
	layer = LYING_MOB_LAYER
	SET_BASE_PIXEL(-24, 0)
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = null
	max_integrity = 300
	cover_amount = 66
	armor_type = /datum/armor/artillery
	var/can_be_undeployed = TRUE
	var/always_anchored = TRUE
	var/undeploy_time = 3 SECONDS
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/spawned_on_undeploy = /obj/machinery/deployable_turret/artillerylight
/datum/armor/artillery
	melee = 10
	bullet = 80
	laser = 60
	energy = 60
	fire = 80
	acid = 10


/obj/vehicle/ridden/artillerylight/welder_act(mob/living/user, obj/item/W)
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


/obj/vehicle/ridden/artillerylight/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "artillery_light_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/artillery_light)

/obj/vehicle/ridden/artillerylight/wrench_act(mob/living/user, obj/item/wrench/used_wrench)
	. = ..()
	if(!can_be_undeployed)
		return
	if(!ishuman(user))
		return
	used_wrench.play_tool_sound(user)
	user.balloon_alert(user,"deploying...")
	if(!do_after(user, undeploy_time))
		return
	var/obj/undeployed_obj = new spawned_on_undeploy(get_turf(src))
	qdel(src)


/obj/vehicle/ridden/artilleryheavy
	name = "M1938 122mm Artillery Gun"
	desc = "A large Soviet howitzer not much newer then the legendary Mosin Nagant, its way to heavy to be safe on the station, and its shell likewise is too dangerous for orbital use."
	icon = 'icons/mecha/supertanks.dmi'
	icon_state = "m1938"
	layer = LYING_MOB_LAYER
	SET_BASE_PIXEL(-40, 0)
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = null
	max_integrity = 450
	cover_amount = 88
	armor_type = /datum/armor/artillery
	var/can_be_undeployed = TRUE
	var/always_anchored = TRUE
	var/undeploy_time = 6 SECONDS
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/spawned_on_undeploy = /obj/machinery/deployable_turret/artilleryheavy
/datum/armor/artillery
	melee = 10
	bullet = 80
	laser = 60
	energy = 60
	fire = 80
	acid = 10


/obj/vehicle/ridden/artilleryheavy/welder_act(mob/living/user, obj/item/W)
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


/obj/vehicle/ridden/artilleryheavy/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "m1938_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/artillery_light)

/obj/vehicle/ridden/artilleryheavy/wrench_act(mob/living/user, obj/item/wrench/used_wrench)
	. = ..()
	if(!can_be_undeployed)
		return
	if(!ishuman(user))
		return
	used_wrench.play_tool_sound(user)
	user.balloon_alert(user,"deploying...")
	if(!do_after(user, undeploy_time))
		return
	var/obj/undeployed_obj = new spawned_on_undeploy(get_turf(src))
	qdel(src)






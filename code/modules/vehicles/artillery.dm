
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
	pass_flags_self = NONE
	max_integrity = 300
	cover_amount = 66
	armor_type = /datum/armor/artillery
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/can_be_undeployed = TRUE
	var/always_anchored = TRUE
	var/undeploy_time = 3 SECONDS
	var/spawned_on_undeploy = /obj/machinery/deployable_turret/artillerylight

/datum/armor/artillery
	melee = 10
	bullet = 80
	laser = 60
	energy = 60
	fire = 80
	acid = 10

/obj/vehicle/ridden/artillerylight/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "artillery_light_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/artillery_light)

/obj/vehicle/ridden/artillerylight/welder_act(mob/living/user, obj/item/welder)
	if(user.istate & ISTATE_HARM)
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		balloon_alert(user, "you're already repairing it!")
		return ITEM_INTERACT_BLOCKING
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it's not damaged!")
		return ITEM_INTERACT_BLOCKING
	if(!welder.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert_to_viewers("started welding [src]", "started repairing [src]")
	audible_message(span_hear("You hear welding."))
	var/did_the_thing
	while(atom_integrity < max_integrity)
		if(!welder.use_tool(src, user, 1.3 SECONDS, volume = 50, amount = 1))
			break
		did_the_thing = TRUE
		atom_integrity += min(10, (max_integrity - atom_integrity))
		audible_message(span_hear("You hear welding."))
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(atom_integrity >= max_integrity) ? "fully" : "partially"] repaired [src]")
	else
		user.balloon_alert_to_viewers("stopped welding [src]", "interrupted the repair!")
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/artillerylight/wrench_act(mob/living/user, obj/item/wrench)
	if(!can_be_undeployed || !ishuman(user) || (user.istate & ISTATE_HARM))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		balloon_alert(user, "you're already undeploying it!")
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert(user, "undeploying...")
	if(wrench.use_tool(src, user, undeploy_time, volume = 50))
		new spawned_on_undeploy(get_turf(src))
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/vehicle/ridden/artilleryheavy
	name = "M1938 122mm Artillery Gun"
	desc = "A large Soviet howitzer not much newer then the legendary Mosin Nagant, its way to heavy to be safe on the station, and its shell likewise is too dangerous for orbital use."
	icon = 'icons/mecha/supertanks.dmi'
	icon_state = "m1938"
	layer = LYING_MOB_LAYER
	SET_BASE_PIXEL(-40, 0)
	max_buckled_mobs = 1
	max_occupants = 1
	pass_flags_self = NONE
	max_integrity = 450
	cover_amount = 88
	armor_type = /datum/armor/artillery
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/can_be_undeployed = TRUE
	var/always_anchored = TRUE
	var/undeploy_time = 6 SECONDS
	var/spawned_on_undeploy = /obj/machinery/deployable_turret/artilleryheavy

/datum/armor/artillery
	melee = 10
	bullet = 80
	laser = 60
	energy = 60
	fire = 80
	acid = 10

/obj/vehicle/ridden/artilleryheavy/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "m1938_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/artillery_light)

/obj/vehicle/ridden/artilleryheavy/welder_act(mob/living/user, obj/item/welder)
	if(user.istate & ISTATE_HARM)
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		balloon_alert(user, "you're already repairing it!")
		return ITEM_INTERACT_BLOCKING
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it's not damaged!")
		return ITEM_INTERACT_BLOCKING
	if(!welder.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert_to_viewers("started welding [src]", "started repairing [src]")
	audible_message(span_hear("You hear welding."))
	var/did_the_thing
	while(atom_integrity < max_integrity)
		if(!welder.use_tool(src, user, 1.3 SECONDS, volume = 50, amount = 1))
			break
		did_the_thing = TRUE
		atom_integrity += min(10, (max_integrity - atom_integrity))
		audible_message(span_hear("You hear welding."))
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(atom_integrity >= max_integrity) ? "fully" : "partially"] repaired [src]")
	else
		user.balloon_alert_to_viewers("stopped welding [src]", "interrupted the repair!")
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/artilleryheavy/wrench_act(mob/living/user, obj/item/wrench)
	if(!can_be_undeployed || !ishuman(user) || (user.istate & ISTATE_HARM))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		balloon_alert(user, "you're already undeploying it!")
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert(user, "undeploying...")
	if(wrench.use_tool(src, user, undeploy_time, volume = 50))
		new spawned_on_undeploy(get_turf(src))
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

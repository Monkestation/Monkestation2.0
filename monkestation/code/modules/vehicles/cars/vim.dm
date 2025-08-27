/obj/vehicle/sealed/car/vim
	/// Air tank used for internals.
	var/obj/item/tank/internals/tank

/obj/vehicle/sealed/car/vim/examine(mob/user)
	. = ..()
	if(!QDELETED(tank))
		. += span_notice("[icon2html(tank, user)] It has \a [tank] mounted onto it.")
	else
		. += span_notice("You could attach an oxygen tank, to make it spaceworthy.")

/obj/vehicle/sealed/car/vim/atom_destruction(damage_flag)
	new /obj/effect/decal/cleanable/robot_debris/limb(drop_location())
	tank?.forceMove(drop_location())
	tank = null
	return ..()

/obj/vehicle/sealed/car/vim/return_air()
	return tank?.return_air() || loc?.return_air()

/obj/vehicle/sealed/car/vim/return_analyzable_air()
	return tank?.return_analyzable_air()

/obj/vehicle/sealed/car/vim/attackby(obj/item/attacking_item, mob/user, params)
	if((user.istate & ISTATE_HARM) || !istype(attacking_item, /obj/item/tank/internals))
		return ..()
	if(!QDELETED(tank))
		to_chat(user, span_warning("[src] already has \the [tank]!"))
		return
	var/obj/item/tank/internals/tank_to_attach = attacking_item
	if(tank_to_attach.return_air()?.return_pressure() <= HAZARD_LOW_PRESSURE)
		to_chat(user, span_warning("[src] does not have enough air!"))
		return
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	user.balloon_alert_to_viewers("attaching air tank...")
	if(!do_after(user, 5 SECONDS, src))
		return
	if(!user.transferItemToLoc(tank_to_attach, src))
		return
	tank = tank_to_attach
	user.balloon_alert_to_viewers("attached air tank")

// Spawns in with a tank.
/obj/vehicle/sealed/car/vim/with_tank

/obj/vehicle/sealed/car/vim/with_tank/Initialize(mapload)
	. = ..()
	tank = new /obj/item/tank/internals/oxygen(src)

/obj/item/light_eater/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/machinery/door/airlock) && !istype(attacked_atom, /obj/machinery/door/window))
		return ..()

	var/obj/machinery/door/opening = attacked_atom

	if(!opening.density) // Don't bother opening that which is already open.
		return

	var/has_power = opening.hasPower()

	if((!opening.requiresID() || opening.allowed(user)) && has_power) // Blocks useless messages for doors we can open normally.
		return ..()

	if(has_power)
		opening.balloon_alert(user, "powered!")
		return ..()

	if(opening.locked)
		opening.balloon_alert(user, "bolted!")
		return ..()

	user.visible_message(
		message = span_warning("[user] forces [opening] to open with [user.p_their()] [src]!"),
		self_message = span_warning("We force [opening] to open."),
		blind_message = span_hear("You hear a metal screeching sound.")
	)

	opening.open(BYPASS_DOOR_CHECKS)

/obj/item/light_eater
	var/datum/proximity_monitor/advanced/nightmare_snuff/nightmare_snuff

	COOLDOWN_DECLARE(message_cooldown)

/obj/item/light_eater/equipped(mob/user, slot, initial)
	. = ..()
	if(get_turf(user)) // If the user is in fucking nullspace, don't make a proximity monitor.
		nightmare_snuff = new(_host = src, range = 2, _ignore_if_not_on_turf = FALSE)

/obj/item/light_eater/dropped(mob/user, silent)
	. = ..()
	QDEL_NULL(nightmare_snuff)

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
		if(check_message_cd())
			opening.balloon_alert(user, "powered!")
		return ..()

	if(opening.locked)
		if(check_message_cd())
			opening.balloon_alert(user, "bolted!")
		return ..()

	user.visible_message(
		message = span_warning("[user] forces [opening] to open with [user.p_their()] [src]!"),
		self_message = span_warning("We force [opening] to open."),
		blind_message = span_hear("You hear a metal screeching sound.")
	)

	opening.open(BYPASS_DOOR_CHECKS)

/obj/item/light_eater/proc/check_message_cd()
	. = COOLDOWN_FINISHED(src, message_cooldown)
	if(.)
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)

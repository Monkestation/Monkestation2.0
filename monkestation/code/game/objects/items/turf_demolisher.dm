//simply an item that breaks turfs down
/obj/item/turf_demolisher
	name = "\improper Exprimental Demolisher"
	icon = 'icons/obj/mining.dmi'
	icon_state = "jackhammer"
	inhand_icon_state = "jackhammer"
	///The balloon_alert() to send when we cannot demolish a turf
	var/unbreakable_alert = "Unable to demolish that."
	///List of turf types we are allowed to break, if unset then we can break any turfs that dont have the INDESTRUCTIBLE resistance flag
	var/list/allowed_types = list(/turf/closed/wall)
	///List of turf types we are NOT allowed to break
	var/list/blacklisted_types
	///How long is the do_after() to break a turf
	var/break_time = 8 SECONDS
	///Do we devastate broken walls, because of quality 7 year old code this always makes iron no matter the wall type
	var/devastate = TRUE
	///How long is our recharge time between uses
	var/recharge_time = 0
	COOLDOWN_DECLARE(recharge)

/obj/item/turf_demolisher/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!isturf(attacked_atom) || (user.istate & ISTATE_HARM))
		return ..()

	if(!check_breakble(attacked_atom, user, params))
		return

	if(try_demolish(attacked_atom, user))
		return
	return ..()

/obj/item/turf_demolisher/proc/check_breakble(turf/attacked_turf, mob/living/user, params)
	if((allowed_types && !is_type_in_list(attacked_turf, allowed_types)) || is_type_in_list(attacked_turf, blacklisted_types) || (attacked_turf.resistance_flags & INDESTRUCTIBLE) || \
		(recharge_time && !COOLDOWN_FINISHED(recharge)))
		if(unbreakable_alert)
			balloon_alert(user, unbreakable_alert)
		return FALSE
	return TRUE

/obj/item/turf_demolisher/proc/try_demolish(turf/attacked_turf, mob/living/user)
	if(iswallturf(attacked_turf))
		var/turf/closed/wall/wall_turf = attacked_turf
		wall_turf.dismantle_wall(devastate)

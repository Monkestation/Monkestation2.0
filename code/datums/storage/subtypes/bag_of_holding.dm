/datum/storage/bag_of_holding/attempt_insert(obj/item/to_insert, mob/user, override, force)
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(to_insert.get_all_contents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= real_location

	if(istype(to_insert, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, PROC_REF(recursive_insertion), to_insert, user)
		return

	return ..()

/datum/storage/bag_of_holding/proc/recursive_insertion(obj/item/to_insert, mob/living/user)
	var/safety = tgui_alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [to_insert.name]?", list("Proceed", "Abort"))
	if(safety != "Proceed" || QDELETED(to_insert) || QDELETED(real_location) || QDELETED(user) || !iscarbon(user) || !user.can_perform_action(real_location, NEED_DEXTERITY))
		return

	var/turf/loccheck = get_turf(real_location)
	to_chat(user, span_danger("The Bluespace interfaces of the two devices catastrophically malfunction!"))
	qdel(to_insert)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	user.log_message("detonated a bag of holding at [loc_name(loccheck)].", LOG_ATTACK, color="red")

	user.investigate_log("has been gibbed by a bag of holding recursive insertion.", INVESTIGATE_DEATHS)
	user.gib(TRUE, TRUE, TRUE)
	new/obj/boh_tear(loccheck)
	qdel(real_location)

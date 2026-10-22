///Warp whistle, spawns a tornado that teleports you
/obj/item/warp_whistle
	name = "warp whistle"
	desc = "Calls a cloud to come pick you up and drop you at a random location on the station."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"

	/// Person using the warp whistle
	var/mob/living/whistler

/obj/item/warp_whistle/attack_self(mob/user)
	if(whistler)
		to_chat(user, span_warning("[src] is on cooldown."))
		return

	whistler = user
	var/turf/current_turf = get_turf(user)
	var/turf/spawn_location = locate(user.x + pick(-7, 7), user.y, user.z)
	playsound(current_turf,'sound/magic/warpwhistle.ogg', 200, TRUE)
	new /obj/effect/temp_visual/teleporting_tornado(spawn_location, src)

///Teleporting tornado, spawned by warp whistle, teleports the user if they manage to pick them up.
/obj/effect/temp_visual/teleporting_tornado
	name = "tornado"
	desc = "This thing sucks!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 8 SECONDS
	movement_type = PHASING

	/// Reference to the whistle
	var/obj/item/warp_whistle/whistle
	/// List of all mobs currently held by the tornado.
	var/list/pickedup_mobs = list()

/obj/effect/temp_visual/teleporting_tornado/Initialize(mapload, obj/item/warp_whistle/whistle)
	. = ..()
	src.whistle = whistle
	if(!whistle)
		qdel(src)
		return
	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(check_teleport))
	SSmove_manager.move_towards(src, get_turf(whistle.whistler))

/// Check if anything the tornado crosses is the creator.
/obj/effect/temp_visual/teleporting_tornado/proc/check_teleport(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(crossed != whistle.whistler || (crossed in pickedup_mobs))
		return

	pickedup_mobs += crossed
	buckle_mob(crossed, TRUE, FALSE)
	ADD_TRAIT(crossed, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)
	animate(src, alpha = 20, pixel_y = 400, time = 3 SECONDS)
	animate(crossed, pixel_y = 400, time = 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(send_away)), 2 SECONDS)

/obj/effect/temp_visual/teleporting_tornado/proc/send_away()
	var/turf/ending_turfs = find_safe_turf()
	for(var/mob/stored_mobs as anything in pickedup_mobs)
		do_teleport(stored_mobs, ending_turfs, channel = TELEPORT_CHANNEL_MAGIC)
		animate(stored_mobs, pixel_y = null, time = 1 SECONDS)
		stored_mobs.log_message("warped with [whistle].", LOG_ATTACK, color = "red")
		REMOVE_TRAIT(stored_mobs, TRAIT_INCAPACITATED, WARPWHISTLE_TRAIT)

/// Destroy the tornado and teleport everyone on it away.
/obj/effect/temp_visual/teleporting_tornado/Destroy()
	if(whistle)
		whistle.whistler = null
		whistle = null
	return ..()

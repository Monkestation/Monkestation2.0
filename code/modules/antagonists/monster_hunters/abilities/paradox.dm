/datum/action/cooldown/paradox
	name = "Paradox Rabbit"
	desc = "The rabbit's movements will be translated onto you, ignoring any solid objects in your way."
	button_icon = 'icons/mob/simple/rabbit.dmi'
	button_icon_state = "rabbit_white_dead"
	cooldown_time = 3 MINUTES
	///the rabbit in question if it exists
	var/mob/living/basic/rabbit/rabbit
	///where the user originally was
	var/turf/original_loc

/datum/action/cooldown/paradox/Activate()
	var/turf/owner_turf = get_turf(owner)
	if(!is_station_level(owner_turf.z))
		to_chat(owner, span_warning("(WRITER TODO) red queen - not here, the coronation happens on the station"))
		return
	var/obj/effect/landmark/wonderchess_mark/chessmark = GLOB.wonderland_marks["Wonderchess landmark"]
	var/obj/effect/landmark/wonderland_mark/landmark = GLOB.wonderland_marks["Wonderland landmark"]
	if(QDELETED(chessmark) || QDELETED(landmark))
		return
	StartCooldown(360 SECONDS)
	var/turf/theplace = get_turf(chessmark)
	var/turf/land_mark = get_turf(landmark)
	original_loc = get_turf(owner)
	var/mob/living/basic/rabbit/bunny = new(theplace)
	if(QDELETED(bunny))
		return
	owner.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), REF(src))
	new /obj/effect/temp_visual/wonderland_hole(original_loc)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(original_loc, owner)
	owner.forceMove(land_mark) ///the user remains safe in the wonderland
	owner.transfer_observers_to(bunny)
	owner.mind.transfer_to(bunny)
	addtimer(CALLBACK(src, PROC_REF(return_to_station), owner, bunny, theplace), 5 SECONDS)
	StartCooldown()

/datum/action/cooldown/paradox/proc/return_to_station(mob/user, mob/bunny, turf/mark)
	var/new_x = bunny.x - mark.x
	var/new_y = bunny.y - mark.y
	var/turf/new_location = locate((original_loc.x + new_x) , (original_loc.y + new_y) , original_loc.z)
	user.forceMove(new_location)
	bunny.transfer_observers_to(user)
	bunny.mind.transfer_to(user)
	user.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), REF(src))
	new /obj/effect/temp_visual/wonderland_hole(new_location)
	climb_out_of_rabbit_hole(user)
	rabbit = null
	original_loc = null
	qdel(bunny)

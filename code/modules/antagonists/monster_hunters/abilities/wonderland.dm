/datum/action/cooldown/wonderland_drop
	name = "To Wonderland"
	button_icon = 'icons/turf/floors.dmi'
	button_icon_state = "junglegrass"
	cooldown_time = 5 MINUTES
	///where the user originally was
	var/turf/original_loc

/datum/action/cooldown/wonderland_drop/Activate()
	var/obj/effect/landmark/wonderland_mark/landmark = GLOB.wonderland_marks["Wonderland landmark"]
	if(QDELETED(landmark))
		return
	StartCooldown(360 SECONDS)
	var/mob/living/sleeper = owner
	original_loc = get_turf(sleeper)
	var/turf/theplace = get_turf(landmark)
	new /obj/effect/temp_visual/wonderland_hole(original_loc)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(original_loc, sleeper)
	sleeper.forceMove(theplace)
	sleeper.Sleeping(2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(awaken), sleeper), 3 SECONDS)

/datum/action/cooldown/wonderland_drop/proc/awaken(mob/living/sleeper)
	to_chat(sleeper, span_warning("(WRITER TODO) red queen - welcome to wonderland, mind ur manners"))
	owner.playsound_local(sleeper, 'sound/ambience/wonderland.ogg', vol = 10)
	addtimer(CALLBACK(src, PROC_REF(return_to_station), sleeper), 1 MINUTES)
	StartCooldown()

/datum/action/cooldown/wonderland_drop/proc/return_to_station(mob/living/sleeper)
	if(QDELETED(original_loc))
		return
	sleeper.forceMove(original_loc)
	new /obj/effect/temp_visual/wonderland_hole(original_loc)
	climb_out_of_rabbit_hole(sleeper)
	to_chat(sleeper, span_warning("(WRITER TODO) red queen - nope, it wasn't a dream"))
	original_loc = null

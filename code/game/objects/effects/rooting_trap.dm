
/obj/effect/rooting_trap
	name = "trap"
	desc = "How did you get trapped in that? Try resisting."
	mouse_opacity = 1
	icon_state = "energynet"
	anchored = 1
	density = 0
	plane = ABOVE_GAME_PLANE
	var/atom/stuck_to
	var/duration = 10 SECONDS

/obj/effect/rooting_trap/singularity_act()
	return

/obj/effect/rooting_trap/singularity_pull()
	return

/obj/effect/rooting_trap/blob_act()
	return


/obj/effect/rooting_trap/Destroy()
	if(stuck_to)
		unbuckle_mob(stuck_to, TRUE)
		REMOVE_TRAIT(stuck_to, TRAIT_IMMOBILIZED, REF(src))
	stuck_to = null
	..()

/obj/effect/rooting_trap/proc/stick_to(atom/A, side = null)
	var/turf/T = get_turf(A)
	if(isspaceturf(T)) //can't nail people down unless there's a turf to nail them to.
		return FALSE
	if(!isliving(A))
		return FALSE
	var/mob/living/M = A
	if(M.stat < 2)
		stuck_to = A
		buckle_mob(A, TRUE)
		ADD_TRAIT(A, TRAIT_IMMOBILIZED, REF(src))

		QDEL_IN(src, duration)

		return TRUE
	return FALSE

/obj/effect/rooting_trap/attack_hand(mob/user)
	unstick_attempt(user)

/obj/effect/rooting_trap/proc/unstick_attempt(mob/user)
	if (do_after(user, 1.5 SECONDS, src))
		unstick()

/obj/effect/rooting_trap/proc/unstick()
	if(stuck_to)
		REMOVE_TRAIT(stuck_to, TRAIT_IMMOBILIZED, REF(src))
	qdel(src)

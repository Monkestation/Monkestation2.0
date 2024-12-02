/obj/item/restraints/handcuffs/cult
	name = "ghastly bindings"
	desc = ""
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "cultcuff"
	breakouttime = 60 SECONDS
	var/datum/antagonist/cult/gaoler

/obj/item/restraints/handcuffs/cult/New()
	..()

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		return

	cult.bindings += src

/obj/item/restraints/handcuffs/cult/Destroy()
	..()

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		return

	cult.bindings -= src

/obj/item/restraints/handcuffs/cult/examine(var/mob/user)
	..()
	if (!isliving(loc))//shouldn't happen unless they get admin spawned
		to_chat(user, span_info("The tentacles flailing out of this egg-like object seem like they're trying to grasp at their surroundings.") )
	else
		var/mob/living/carbon/C = loc
		if (C.handcuffed == src)
			to_chat(user, span_info("These restrict your arms and inflict tremendous pain upon both your body and psyche. But given some time you should be able to break them.") )
		else
			to_chat(user, span_info("\The [C] seems to be in pain as these restrict their arms.") )

/obj/item/restraints/handcuffs/cult/narsie_act()
	return

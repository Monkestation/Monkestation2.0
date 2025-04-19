
/datum/cult_tattoo/shortcut
	name = TATTOO_SHORTCUT
	desc = "Place sigils on walls that allows cultists to jump right through."
	icon_state = "shortcut"
	tier = 3
	blood_cost = 5

/turf/closed/wall/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(IS_CULTIST(user) && !(locate(/obj/effect/cult_shortcut) in src))
		var/datum/cult_tattoo/CT = user.checkTattoo(TATTOO_SHORTCUT)
		if(!CT)
			return
		var/mob/living/carbon/carbon = user
		if(carbon.occult_muted())
			return
		var/data = use_available_blood(user, CT.blood_cost)
		if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
			return
		if(!do_after(user, 30, src))
			return
		new /obj/effect/cult_shortcut(src)
		user.visible_message("<span class='warning'>[user] has painted a strange sigil on \the [src].</span>", \
						"<span class='notice'>You finish drawing the sigil.</span>")
		var/datum/antagonist/cult/cultist = user.mind?.has_antag_datum(/datum/antagonist/cult)
		cultist.gain_devotion(5, DEVOTION_TIER_4, "shortcut_sigil", src)

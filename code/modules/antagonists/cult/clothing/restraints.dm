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

/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s shackles shatter in a discharge of dark magic!"), \
							span_userdanger("Your [src] shatters in a discharge of dark magic!"))
	. = ..()

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper Nar'Sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'Sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	inhand_icon_state = "bola_cult"
	breakouttime = 6 SECONDS
	knockdown = 30

#define CULT_BOLA_PICKUP_STUN (6 SECONDS)
/obj/item/restraints/legcuffs/bola/cult/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()

	if(IS_CULTIST(user) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	if(user.num_legs < 2 || carbon_user.legcuffed) //if they can't be ensnared, stun for the same time as it takes to breakout of bola
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(CULT_BOLA_PICKUP_STUN)
	else
		to_chat(user, span_warning("The bola seems to take on a life of its own!"))
		ensnare(user)
#undef CULT_BOLA_PICKUP_STUN


/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/hit_mob = hit_atom
	if (istype(hit_mob) && IS_CULTIST(hit_mob))
		return
	. = ..()

/obj/item/weapon/bloodcult_pamphlet
	name = "cult of Nar-Sie pamphlet"
	desc = "Looks like a page torn from one of those cultist tomes. It is titled \"Ten reasons why Nar-Sie can improve your life!\""
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state ="pamphlet"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1

/obj/item/weapon/bloodcult_pamphlet/attack_self(mob/user, modifiers)
	if (IS_CULTIST(user))
		return
	var/datum/antagonist/cult/new_cultist = new /datum/antagonist/cult()
	new_cultist.cult_team = new_cultist.get_team()
	user.mind.add_antag_datum(new_cultist)

/obj/item/weapon/bloodcult_pamphlet/oneuse/attack_self(mob/user, modifiers)
	..()
	qdel(src)

/obj/item/weapon/bloodcult_pamphlet/salt_act()
	fire_act(1000, 200)

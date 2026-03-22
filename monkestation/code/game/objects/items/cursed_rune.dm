/obj/item/bad_luck
	name = "cursed slab"
	desc = "An ancient stone slab with writing in an unknown language upon it."
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state ="slab"
	var/can_curse = 1
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bad_luck/equipped(mob/user, slot, initial)
	. = ..()
	if(!can_curse)
		return
	if(curse(user))
		can_curse--
		user.balloon_alert(user, "the slabs curse has been passed on.")


/obj/item/bad_luck/proc/curse(mob/user)
	if(!iscarbon(user))
		user.balloon_alert(user, "the curse does not effect you...")
		return FALSE
	var/datum/smite/bad_luck/cursed = new /datum/smite/bad_luck
	cursed.incidents = 13
	cursed.effect(user.client, user)

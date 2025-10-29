/obj/structure/weaponsmith
	name = "Weapon Forge"
	desc = "Fueled by the tears of rabbits."
	icon = 'icons/obj/cult/structures.dmi'
	icon_state = "altar"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	move_resist = INFINITY

/obj/structure/weaponsmith/examine(mob/user)
	. = ..()
	. += span_info("To upgrade your weapon, first place it on the forge, then use a <b>rabbit eye</b> on the forge.")

/obj/structure/weaponsmith/attack_hand(mob/living/user, list/modifiers)
	if(locate(/obj/item/melee/trick_weapon) in loc)
		balloon_alert(user, "use a rabbit eye on the forge!")
	else
		balloon_alert(user, "place your weapon on the forge!")

/obj/structure/weaponsmith/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/melee/trick_weapon))
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_BLOCKING
		tool.forceMove(loc)
		balloon_alert(user, "weapon placed")
		return ITEM_INTERACT_SUCCESS
	else if(istype(tool, /obj/item/rabbit_eye))
		var/obj/item/melee/trick_weapon/trick_weapon = locate() in loc
		if(!trick_weapon)
			balloon_alert(user, "place your weapon on the forge first!")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/rabbit_eye/eye = tool
		eye.upgrade(trick_weapon, user)
		user.log_message("upgraded their [trick_weapon] using a Rabbit Eye", LOG_GAME)
		return ITEM_INTERACT_SUCCESS
	return NONE

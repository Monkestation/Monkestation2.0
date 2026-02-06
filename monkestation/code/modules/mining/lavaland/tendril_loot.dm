/obj/item/clothing/neck/necklace/memento_mori/attack_hand(mob/user, list/modifiers)
	if(prevent_accidental_suicide(user))
		return
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(prevent_accidental_suicide(over_location))
		return
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/prevent_accidental_suicide(mob/user)
	if(user == active_owner && tgui_alert(user, "Taking this off will INSTANTLY KILL YOU! Are you really sure you want to take it off?", "Memento Mori", list("Yes", "No")) != "Yes")
		return TRUE
	return FALSE

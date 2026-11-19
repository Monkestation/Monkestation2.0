/// A flag on a pole. It can be rolled up, and burns with flames shaped to the cloth.
/obj/item/flag
	name = "flag"
	desc = "It's a flag."
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "voxflag"
	lefthand_file = 'icons/obj/species/vox/items_lefthand.dmi'
	righthand_file = 'icons/obj/species/vox/items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	/// Is the flag rolled up around its pole?
	var/rolled = FALSE

/obj/item/flag/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/flag/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(item.get_temperature() && !(resistance_flags & ON_FIRE))
		user.visible_message(span_notice("[user] lights [src] with [item]."), span_notice("You light [src] with [item]."), span_hear("You hear a low whoosh."))
		fire_act()

/obj/item/flag/attack_self(mob/user)
	rolled = !rolled
	user.visible_message(span_notice("[user] [rolled ? "rolls up" : "unfurls"] [src]."), span_notice("You [rolled ? "roll up" : "unfurl"] [src]."), span_hear("You hear fabric rustling."))
	update_appearance()

/obj/item/flag/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	update_appearance()

/obj/item/flag/extinguish()
	. = ..()
	update_appearance()

/obj/item/flag/update_icon_state()
	icon_state = "[initial(icon_state)][rolled ? "_rolled" : ""]"
	inhand_icon_state = "[initial(icon_state)][(resistance_flags & ON_FIRE) ? "_fire" : ""]"
	custom_fire_overlay = mutable_appearance(icon, rolled ? "flag_fire_rolled" : "flag_fire", appearance_flags = RESET_COLOR)
	return ..()

/obj/item/flag/species/vox
	name = "\improper Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	icon_state = "voxflag"

/obj/item/clothing/neck/crucifix
	name = "crucifix"
	desc = "In the event that one of those you falsely accused is, in fact, a real witch, this will ward you against their curses."
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "crucifix"
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	worn_icon_state = "cross"

/obj/item/clothing/neck/crucifix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE_HOLY, \
		inventory_flags = ITEM_SLOT_HANDS, \
	)

/obj/item/clothing/neck/crucifix/rosary
	name = "rosary beads"
	desc = "A wooden crucifix meant to ward off curses and hexes."
	resistance_flags = FLAMMABLE
	icon_state = "rosary"

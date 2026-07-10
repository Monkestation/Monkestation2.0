// Tribal undershirt accessories, made from bone or sinew.
/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	attachment_slot = NONE

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	attachment_slot = GROIN

/obj/item/clothing/accessory/skilt
	name = "Sinew Skirt"
	desc = "For the last time. IT'S A KILT not a skirt."
	icon_state = "skilt"
	minimize_when_attached = FALSE
	attachment_slot = GROIN

/obj/item/clothing/accessory/talisman
	armor_type = /datum/armor/accessory_talisman

/datum/armor/accessory_talisman
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	acid = 25

/obj/item/clothing/accessory/skullcodpiece
	armor_type = /datum/armor/accessory_skullcodpiece

/datum/armor/accessory_skullcodpiece
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	acid = 25

/obj/item/clothing/accessory/skilt
	armor_type = /datum/armor/accessory_skilt

/datum/armor/accessory_skilt
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	acid = 25

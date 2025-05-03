/obj/item/clothing/suit/toggle/labcoat/xenobiologist
	name = "xenobiologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a pink stripe on the shoulder."
	icon_state = "labcoat_xeno"

/obj/item/clothing/suit/toggle/labcoat/xenobiologist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno

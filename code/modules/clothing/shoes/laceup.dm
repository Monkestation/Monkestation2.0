/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	equip_delay_other = 50
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK
	bodyshapes_with_variations = BODYSHAPE_DIGITIGRADE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR

/obj/item/clothing/shoes/laceup/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 3) //You aren't going to fish with these are you?
	AddComponent(/datum/component/shoesteps/tap_shoes)

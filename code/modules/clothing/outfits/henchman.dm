/obj/item/clothing/head/henchmen_hat
	name = "henchmen cap"
	desc = "Alright boss.. I'll handle it."
	icon = 'icons/mob/clothing/costumes/henchmen/henchmen_item.dmi'
	worn_icon = 'icons/mob/clothing/costumes/henchmen/henchmen_worn.dmi'
	icon_state = "greyscale_cap"
	greyscale_colors = "#201b1a"
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/henchmen_coat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/jacket/henchmen_coat
	name = "henchmen coat"
	desc = "Alright boss.. I'll handle it."
	icon = 'icons/mob/clothing/costumes/henchmen/henchmen_item.dmi'
	worn_icon = 'icons/mob/clothing/costumes/henchmen/henchmen_worn.dmi'
	icon_state = "greyscale_coat"
	greyscale_colors = "#201b1a"
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/henchmen_hat/traitor
	name = "armored henchmen cap"
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	armor_type = /datum/armor/suit_armor
	greyscale_colors = "#240d0d"

/obj/item/clothing/suit/jacket/henchmen_coat/traitor
	name = "armored henchmen coat"
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	armor_type = /datum/armor/suit_armor
	greyscale_colors = "#240d0d"

/obj/item/clothing/head/henchmen_hat
	name = "henchmen cap"
	desc = "Alright boss.. I'll handle it."
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	SETUP_MAP_ICONS("greyscale_cap", "/obj/item/clothing/head/henchmen_hat")
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	greyscale_colors = "#201b1a"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/henchmen_coat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/head/henchmen_hat/traitor
	name = "armored henchmen cap"
	SETUP_MAP_ICONS("greyscale_cap", "/obj/item/clothing/head/henchmen_hat/traitor")
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	greyscale_colors = "#240d0d"
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/suit/jacket/henchmen_coat
	name = "henchmen coat"
	desc = "Alright boss.. I'll handle it."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	SETUP_MAP_ICONS("greyscale_coat", "/obj/item/clothing/suit/jacket/henchmen_coat")
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	greyscale_colors = "#201b1a"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/henchmen_coat/traitor
	name = "armored henchmen coat"
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	SETUP_MAP_ICONS("greyscale_coat", "/obj/item/clothing/suit/jacket/henchmen_coat/traitor")
	greyscale_colors = "#240d0d"
	armor_type = /datum/armor/suit_armor

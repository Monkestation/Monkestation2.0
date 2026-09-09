//Just some alt-uniforms themed around Star Trek - Pls don't sue, Mr Roddenberry ;_;

/obj/item/clothing/under/trek
	can_adjust = FALSE
	icon = 'icons/obj/clothing/under/trek.dmi'
	worn_icon = 'icons/mob/clothing/under/trek.dmi'

/*
*	The Original Series (Technically not THE original because these have a black undershirt while the very-original didn't but IDC)
*/
/obj/item/clothing/under/trek/command
	name = "command uniform"
	desc = "An outdated uniform worn by command officers."
	inhand_icon_state = "y_suit"
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	SETUP_MAP_ICONS("trek_tos_com", "/obj/item/clothing/under/trek/command")
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#fab342"

/obj/item/clothing/under/trek/engsec
	name = "engsec uniform"
	desc = "An outdated uniform worn by engineering/security officers."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	SETUP_MAP_ICONS("trek_tos_sec", "/obj/item/clothing/under/trek/engsec")
	inhand_icon_state = "r_suit"
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#B72B2F"

/obj/item/clothing/under/trek/medsci
	name = "medsci uniform"
	desc = "An outdated worn by medical/science officers."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	SETUP_MAP_ICONS("trek_tos", "/obj/item/clothing/under/trek/medsci")
	inhand_icon_state = "b_suit"
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#5FA4CC"

/*
*	The Next Generation
*/
/obj/item/clothing/under/trek/command/next
	SETUP_MAP_ICONS("trek_next", "/obj/item/clothing/under/trek/command/next") //Technically TNG had Command wearing red, but bc gold is closer to command roles for SS13 we're taking some liberties

/obj/item/clothing/under/trek/engsec/next
	SETUP_MAP_ICONS("trek_next", "/obj/item/clothing/under/trek/engsec/next")

/obj/item/clothing/under/trek/medsci/next
	SETUP_MAP_ICONS("trek_next", "/obj/item/clothing/under/trek/medsci/next")

/*
*	Voyager
*/
/obj/item/clothing/under/trek/command/voy
	SETUP_MAP_ICONS("trek_voy", "/obj/item/clothing/under/trek/command/voy") //Same point applies as TNG

/obj/item/clothing/under/trek/engsec/voy
	SETUP_MAP_ICONS("trek_voy", "/obj/item/clothing/under/trek/engsec/voy")

/obj/item/clothing/under/trek/medsci/voy
	SETUP_MAP_ICONS("trek_voy", "/obj/item/clothing/under/trek/medsci/voy")

/*
*	Enterprise
*/
/obj/item/clothing/under/trek/command/ent
	SETUP_MAP_ICONS("trek_ent", "/obj/item/clothing/under/trek/command/ent")
	//Greyscale sprite note, the base of it can't be greyscaled lest I make a whole new .json, but the color bands are greyscale at least.
	//I've left a greyscale version of it in color.dmi in case someone wants a pocketed-jumpsuit/'coveralls' without the color bands - Orion_the_Fox
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/engsec/ent
	SETUP_MAP_ICONS("trek_ent", "/obj/item/clothing/under/trek/engsec/ent")
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/medsci/ent
	SETUP_MAP_ICONS("trek_ent", "/obj/item/clothing/under/trek/medsci/ent")
	inhand_icon_state = "bl_suit"

//Q
/obj/item/clothing/under/trek/q
	name = "french marshall's uniform"
	desc = "Something about this uniform feels off..."
	icon_state = "trek_Q"
	inhand_icon_state = "r_suit"

/obj/item/clothing/suit/costume/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	species_exception = list(/datum/species/golem)
	///How many times has this shirt been washed? (In an ideal world this is just the determinant of the transform matrix.)
	var/wash_count = 0

/obj/item/clothing/suit/costume/ianshirt/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	if(wash_count <= 5)
		transform *= TRANSFORM_USING_VARIABLE(0.8, 1)
		washer.visible_message("[src] appears to have shrunken after being washed.")
		wash_count += 1
	else
		washer.visible_message("[src] implodes due to repeated washing.")
		qdel(src)

/obj/item/clothing/suit/costume/wellworn_shirt
	name = "well-worn shirt"
	desc = "A worn out, curiously comfortable t-shirt. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	inhand_icon_state = null
	icon = 'icons/map_icons/clothing/suit/costume.dmi'
	SETUP_MAP_ICONS("wellworn_shirt", "/obj/item/clothing/suit/costume/wellworn_shirt")
	greyscale_config = /datum/greyscale_config/wellworn_shirt
	greyscale_config_worn = /datum/greyscale_config/wellworn_shirt/worn
	greyscale_colors = COLOR_WHITE
	species_exception = list(/datum/species/golem)
	flags_1 = IS_PLAYER_COLORABLE_1
	///How many times has this shirt been washed? (In an ideal world this is just the determinant of the transform matrix.)
	var/wash_count = 0

/obj/item/clothing/suit/costume/wellworn_shirt/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	if(wash_count <= 5)
		transform *= TRANSFORM_USING_VARIABLE(0.8, 1)
		washer.visible_message("[src] appears to have shrunken after being washed.")
		wash_count += 1
	else
		washer.visible_message("[src] implodes due to repeated washing.")
		qdel(src)

/obj/item/clothing/suit/costume/wellworn_shirt/skub
	name = "pro-skub shirt"
	desc = "A worn out, curiously comfortable t-shirt proclaiming your pro-skub stance. Fuck those anti-skubbies."
	greyscale_colors = "#FFFF4D"
	SETUP_MAP_ICONS("wellworn_shirt_pro_skub", "/obj/item/clothing/suit/costume/wellworn_shirt/skub")
	greyscale_config = /datum/greyscale_config/wellworn_shirt_skub
	greyscale_config_worn = /datum/greyscale_config/wellworn_shirt_skub/worn

/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti
	name = "anti-skub shirt"
	desc = "A worn out, curiously comfortable t-shirt proclaiming your anti-skub stance. Fuck those pro-skubbies."
	SETUP_MAP_ICONS("wellworn_shirt_anti_skub", "/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti")

/obj/item/clothing/suit/costume/nerdshirt
	name = "gamer shirt"
	desc = "A baggy shirt with vintage game character Phanic the Weasel. Why would anyone wear this?"
	icon_state = "nerdshirt"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

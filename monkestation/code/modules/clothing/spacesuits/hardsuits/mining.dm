//----------------
// Mining Hardsuit
//----------------
/obj/item/clothing/suit/space/hardsuit/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	icon_state = "hardsuit-mining"
	armor_type = /datum/armor/hardsuit/mining/explorer
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/mining
	allowed = null

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)
	allowed = GLOB.mining_suit_allowed

/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	armor_type = /datum/armor/hardsuit/mining/explorer
	hardsuit_type = "mining"
	light_outer_range = 7

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

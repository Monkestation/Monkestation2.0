/obj/item/clothing/head/hooded/cult_hoodie
	name = "ancient cultist hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "culthood"
	inhand_icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/hooded_cult_hoodie

	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT

	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/datum/armor/hooded_cult_hoodie
	melee = 40
	bullet = 30
	laser = 40
	energy = 40
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

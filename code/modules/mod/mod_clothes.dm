/obj/item/clothing/head/mod
	name = "MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-helmet"
	base_icon_state = "helmet"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HEAD


	item_flags = IMMUTABLE_SLOW
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)

/obj/item/clothing/suit/mod
	name = "MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-chestplate"
	base_icon_state = "chestplate"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/flashlight,
		/obj/item/tank/jetpack/oxygen/captain,
	)
	armor_type = /datum/armor/none
	body_parts_covered = CHEST|GROIN


	item_flags = IMMUTABLE_SLOW
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)

/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-gauntlets"
	base_icon_state = "gauntlets"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HANDS|ARMS
	item_flags = IMMUTABLE_SLOW

/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-boots"
	base_icon_state = "boots"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = FEET|LEGS


	item_flags = IMMUTABLE_SLOW
	item_flags = IGNORE_DIGITIGRADE
	can_be_tied = FALSE

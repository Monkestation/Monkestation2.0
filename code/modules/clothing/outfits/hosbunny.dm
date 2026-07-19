/obj/item/clothing/head/playbunnyears/hos
	name = "head of security's bunny ears"
	desc = "Red and gold bunny ears attached to a headband. Shows your authority over all bunny officers."
	icon_state = "hos"
	icon = 'icons/obj/clothing/bunnysprites/bunny_ears.dmi'
	worn_icon = 'icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/hats_hos
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/security/head_of_security/bunnysuit
	desc = "The staple of any bunny themed security commanders. Includes kevlar weave stockings and a gilded tail."
	name = "Head of Security's bunnysuit"
	icon_state = "bunnysuit_hos"
	icon = 'icons/obj/clothing/bunnysprites/bunnysuits.dmi'
	worn_icon = 'icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/head_of_security/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/hos_tailcoat
	name = "head of security's tailcoat"
	desc = "A reinforced tailcoat worn by bunny themed security commanders. Enhanced with a special alloy for some extra protection and style."
	icon_state = "hos"
	inhand_icon_state = "armor"
	icon = 'icons/obj/clothing/bunnysprites/tailcoats.dmi'
	worn_icon = 'icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	dog_fashion = null
	armor_type = /datum/armor/armor_hos
	strip_delay = 80

/obj/item/clothing/neck/tie/bunnytie/security
	name = "security bowtie"
	desc = "A red tie that includes a collar. Looking tough!"
	icon = 'icons/obj/clothing/bunnysprites/neckwear.dmi'
	worn_icon = 'icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_sec_tied"
	tie_type = "bowtie_collar_sec"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

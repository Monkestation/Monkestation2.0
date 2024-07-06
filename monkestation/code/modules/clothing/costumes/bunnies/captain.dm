/obj/item/clothing/head/hats/caphat/bunnyears_captain
	name = "captain's bunny ears"
	desc = "A pair of dark blue bunny ears attached to a headband. Worn in lieu of the more traditional bicorn hat."
	icon_state = "captain"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	inhand_icon_state = "that"
	armor_type = /datum/armor/bunny_ears_captain
	dog_fashion = null

/datum/armor/bunny_ears_captain
	melee = 20
	bullet = 10
	laser = 20
	energy = 30
	bomb = 20
	fire = 50
	acid = 50
	wound = 5

/obj/item/clothing/under/rank/captain/bunnysuit
	desc = "The staple of any bunny themed captains. Great for securing the disk."
	name = "captain's bunnysuit"
	icon_state = "bunnysuit_captain"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/captain/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/vest/capcarapace/tailcoat_captain
	name = "captain's tailcoat"
	desc = "A nautical coat usually worn by bunny themed captains. It’s reinforced with genetically modified armored blue rabbit fluff."
	icon_state = "captain"
	inhand_icon_state = "armor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	armor_type = /datum/armor/tailcoat_captain
	dog_fashion = null

/datum/armor/tailcoat_captain
	melee = 40
	bullet = 30
	laser = 40
	energy = 40
	bomb = 25
	fire = 70
	acid = 70
	wound = 10

/obj/item/clothing/neck/tie/bunnytie/captain
	name = "captain's bowtie"
	desc = "A blue tie that includes a collar. Looking commanding!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_captain_tied"
	tie_type = "bowtie_collar_captain"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/captain/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/captain
	greyscale_colors = "#41579a"
	flags_1 = null

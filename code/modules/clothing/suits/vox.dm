/obj/item/clothing/suit/hooded/vox_robes
	species_restricted = list(/datum/species/vox)
	name = "alien hooded robes"
	desc = "Large, comfortable robes worn by those who need a bit more covering. The thick fabric contains a pocket suitable for those that need their hands free during their work, while the cloth serves to cover scars or other injuries to the wearer's body."
	icon = 'icons/mob/clothing/species/vox/suit.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-robes"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/vox_robe_hood

/obj/item/clothing/head/hooded/vox_robe_hood
	name = "alien hood"
	desc = "The thick fabric of this hood serves a variety of purposes to the vox wearing it - serving as a method to hide a scarred face or a way to keep warm in the coldest areas onboard the ship."
	icon = 'icons/mob/clothing/species/vox/head.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/head.dmi'
	icon_state = "vox-robes-hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/datum/armor/vox_scrap //Higher melee armor versus lower everything else.
	melee = 70
	bullet = 30
	laser = 20
	energy = 5
	bomb = 40
	fire = 50
	acid = 50
	wound = 15

/obj/item/clothing/suit/armor/vox_scrap
	species_restricted = list(/datum/species/vox)
	name = "rusted metal armor"
	desc = "A hodgepodge of various pieces of metal scrapped together into a rudimentary vox-shaped piece of armor."
	icon = 'icons/obj/species/vox/suits.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-scrap"
	inhand_icon_state = "armor"
	allowed = list(/obj/item/gun, /obj/item/tank)
	armor_type = /datum/armor/vox_scrap
	body_parts_covered = CHEST|ARMS|GROIN|LEGS

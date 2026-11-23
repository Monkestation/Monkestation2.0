// Vox space gear: vacuum suits and low pressure armour, shaped for vox

/datum/armor/vox_space
	melee = 40
	bullet = 40
	laser = 30
	energy = 15
	bomb = 30
	bio = 30
	fire = 80
	acid = 85

/obj/item/clothing/suit/space/vox
	species_restricted = list(/datum/species/vox)
	icon = 'icons/obj/species/vox/suits.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-pressure" // the base type would otherwise use the generic space suit's sprite, which our icon file lacks
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
	)
	armor_type = /datum/armor/vox_space
	slowdown = 2

/obj/item/clothing/head/helmet/space/vox
	species_restricted = list(/datum/species/vox)
	icon = 'icons/obj/species/vox/hats.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/head.dmi'
	icon_state = "vox-pressure" // the base type would otherwise use the generic space helmet's sprite, which our icon file lacks
	armor_type = /datum/armor/vox_space
	clothing_flags = STOPSPRESSUREDAMAGE // as on Yogstation: not syringe-proof, and vox breathe through their own masks
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	icon_state = "vox-pressure"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	icon_state = "vox-pressure"

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	icon_state = "vox-carapace"

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	icon_state = "vox-carapace"
	slowdown = 1

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	desc = "A smoothly contoured, matte-black alien helmet."
	icon_state = "vox-stealth"

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."
	icon_state = "vox-stealth"

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	desc = "An alien helmet with enormous goggled lenses."
	icon_state = "vox-medic"

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	desc = "An almost organic looking nonhuman pressure suit."
	icon_state = "vox-medic"

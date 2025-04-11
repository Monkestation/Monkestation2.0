/obj/item/clothing/suit/hooded/cultrobes/hardened
	name = "\improper Nar'Sien hardened armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon = 'monkestation/code/modules/bloody_cult/icons/worn/suit.dmi'
	worn_icon = 'monkestation/code/modules/bloody_cult/icons/worn/suit.dmi'
	icon_state = "cultarmor"
	hood_up_affix = null

	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/weapon/tome, /obj/item/weapon/melee/cultblade, /obj/item/weapon/melee/soulblade, /obj/item/tank, /obj/item/weapon/tome, /obj/item/weapon/talisman, /obj/item/weapon/blood_tesseract)
	armor_type = /datum/armor/cultrobes_hardened
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	flags_inv = HIDEGLOVES | HIDEJUMPSUIT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/suit/hooded/cultrobes/hardened/salt_act()
	acid_melt()

/datum/armor/cultrobes_hardened
	melee = 50
	bullet = 40
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/head/hooded/cult_hoodie/hardened
	name = "\improper Nar'Sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "culthelmet"
	icon = 'monkestation/code/modules/bloody_cult/icons/worn/head.dmi'
	worn_icon = 'monkestation/code/modules/bloody_cult/icons/worn/head.dmi'

	inhand_icon_state = null
	armor_type = /datum/armor/cult_hoodie_hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE

/datum/armor/cult_hoodie_hardened
	melee = 50
	bullet = 40
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

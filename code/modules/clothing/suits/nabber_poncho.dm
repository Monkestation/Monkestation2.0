/obj/item/clothing/suit/costume/nabber_poncho
	species_exception = list(/datum/species/nabber) //ensure nabbers can wear ponchos.
	name = "Giant Poncho"
	desc = "Departmental poncho, mainly used by species with biology that makes it hard to wear most outerwear."
	icon = 'icons/mob/clothing/suits/poncho.dmi'
	worn_icon = 'icons/mob/clothing/suits/poncho.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	icon_state = "classicponcho-0"
	allowed = list(
		/obj/item/crowbar,
		/obj/item/extinguisher,
		/obj/item/flashlight,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/tank/internals,
	)


/obj/item/clothing/suit/costume/nabber_poncho/cargo
	name = "Cargo Poncho"
	icon_state = "cargoponcho-0"

/obj/item/clothing/suit/costume/nabber_poncho/engi
	name = "Engineering Poncho"
	icon_state = "engiponcho-0"

/obj/item/clothing/suit/costume/nabber_poncho/medbay
	name = "Medbay Poncho"
	icon_state = "medponcho-0"

/obj/item/clothing/suit/costume/nabber_poncho/security
	name = "Security Poncho"
	icon_state = "secponcho-0"

/obj/item/clothing/suit/costume/nabber_poncho/science
	name = "Science Poncho"
	icon_state = "sciponcho_nt-0"

/obj/item/clothing/suit/costume/nabber_poncho/fireresistant
	name = "Fire-resistant Poncho"
	desc = "This poncho was designed to protect the user from extreme heat at the cost of significant slowdown."
	icon_state = "sciponcho"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	resistance_flags = FIRE_PROOF
	slowdown = 1.5

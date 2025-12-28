/obj/item/clothing/suit/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	icon = 'icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat.dmi'
	worn_icon_digitigrade = 'icons/mob/clothing/suits/labcoat_digi.dmi'
	inhand_icon_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(
		/obj/item/analyzer,
		/obj/item/biopsy_tool,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/gun/syringe,
		/obj/item/sensor_device,
		/obj/item/soap,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		)
	armor_type = /datum/armor/toggle_labcoat
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	inhand_icon_state = null

/datum/armor/toggle_labcoat
	bio = 50
	fire = 50
	acid = 50

/obj/item/clothing/suit/toggle/labcoat/cmo/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
	)

/obj/item/clothing/suit/toggle/labcoat/paramedic
	name = "paramedic's jacket"
	desc = "A dark blue jacket for paramedics with reflective stripes."
	icon_state = "labcoat_paramedic"
	inhand_icon_state = null
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\proper The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem"

/obj/item/clothing/suit/toggle/labcoat/chemist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/chemistry

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir"

/obj/item/clothing/suit/toggle/labcoat/virologist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/bio

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_sci"

/obj/item/clothing/suit/toggle/labcoat/science/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno

/obj/item/clothing/suit/toggle/labcoat/roboticist
	name = "roboticist labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon_state = "labcoat_robo"

/obj/item/clothing/suit/toggle/labcoat/interdyne
	name = "interdyne labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon_state = "labcoat_robo"

/obj/item/clothing/suit/toggle/labcoat/xenobiologist
	name = "xenobiologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a pink stripe on the shoulder."
	icon_state = "labcoat_xeno"

/obj/item/clothing/suit/toggle/labcoat/xenobiologist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno

/obj/item/clothing/suit/toggle/labcoat/medical
	name = "medical labcoat"
	desc = "A suit that protects against minor chemical spills. Has a light blue stripe on the shoulder."
	icon_state = "labcoat_med"

/obj/item/clothing/suit/toggle/labcoat/secmed
	name = "security medical labcoat"
	desc = "A suit that protects against minor chemical spills. Has a red stripe on the shoulder."
	icon_state = "labcoat_secmed"

/obj/item/clothing/suit/toggle/labcoat/secmed/Initialize(mapload)
	. = ..()
	allowed |= GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/labcoat/secmed/old
	name = "grey security medical labcoat"
	desc = "A formerly retired labcoat pattern now brought back for those working the medical profession in the security apparatus."
	icon_state = "labcoat_secmed_old"

/obj/item/clothing/suit/toggle/labcoat/secmed/alt
	name = "security medical jacket"
	desc = "A red lightly armored jacket with reflective stripes for security medical personnel."
	icon_state = "labcoat_secmed_alt"
	inhand_icon_state = null
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	armor_type = /datum/armor/armor_secjacket

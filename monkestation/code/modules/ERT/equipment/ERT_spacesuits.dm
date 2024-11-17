/datum/armor/ert
	melee = 40
	bullet = 30
	laser = 40 // FF
	energy = 40
	bomb = 30
	bio = 30
	fire = 80
	acid = 85
	wound = 10

/obj/item/clothing/suit/space/ert
	name = "emergency response team space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance." // simple description could use more tho
	icon = 'monkestation/icons/obj/clothing/ERT/ERT_spacesuit_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/ERT/ERT_spacesuit_worn.dmi'
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/ERT/ERT_spacesuit_worn-digi.dmi'
	icon_state = "ert-generic"
	//lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'   do i dare make inhand sprites
	//righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	slowdown = 0 //agile
	max_integrity = 300
	armor_type = /datum/armor/ert
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this feels right?
	cell = /obj/item/stock_parts/cell/bluespace

/obj/item/clothing/suit/space/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/clothing/head/helmet/space/ert
	name = "emergency response team space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon = 'monkestation/icons/obj/clothing/ERT/ERT_helmet_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/ERT/ERT_helmet_worn.dmi'
	icon_state = "ert-generic0"
	//styling
	var/style = "generic"
	worn_icon_snouted = 'monkestation/icons/mob/clothing/ERT/ERT_helmet_worn-digi.dmi'
	max_integrity = 300
	armor_type = /datum/armor/ert
	resistance_flags = ACID_PROOF | FIRE_PROOF
	//helmet light
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 5
	light_power = 1
	light_on = FALSE
	var/on = FALSE

/obj/item/clothing/head/helmet/space/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/clothing/head/helmet/space/ert/attack_self(mob/user)
	on = !on
	icon_state = "ert-[style][on]"
	user.update_worn_head()

	set_light_on(on)

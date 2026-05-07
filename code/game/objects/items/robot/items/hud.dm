/obj/item/borg/sight
	desc = "The module of additional sensors is activated in the upper panel. Retention in the active module is not required."
	var/sight_mode = null
	actions_types = list(/datum/action/item_action/borg_sight)

/obj/item/borg/sight/ui_action_click(mob/user, actiontype)
	var/mob/living/silicon/robot/borg = user
	if(borg.sight_mode)
		borg.sight_mode = 0
		borg.update_sight()
	else
		borg.sight_mode |= sight_mode
		borg.update_sight()

/datum/action/item_action/borg_sight
	name = "Switch Optical Sensors"
	desc = "Switches the optical sensors of the cyborg to alternative available models."


/obj/item/borg/sight/xray
	name = "\proper X-ray vision"
	icon = 'icons/obj/signs.dmi'
	icon_state = "securearea"
	sight_mode = BORGXRAY

/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"

/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"

/obj/item/borg/sight/meson/nightvision
	name = "\proper bright meson vision"
	sight_mode = BORGNVMESON
	icon_state = "meson"

/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null

/obj/item/borg/sight/hud/Initialize(mapload)
	if (!isnull(hud))
		hud = new hud(src)
	return ..()

/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"
	hud = /obj/item/clothing/glasses/hud/health

/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"
	hud = /obj/item/clothing/glasses/hud/security

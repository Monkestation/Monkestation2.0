GLOBAL_VAR_INIT(permit_pin_unrestricted, FALSE)
// Firing pin that can be used off station freely, and requires a permit to use on-station
/obj/item/firing_pin/permit_pin
	name = "permit-locked firing pin"
	desc = "A firing pin for a station who can't trust their crew. Only allows you to fire the weapon off-station or with a firearms permit.."
	icon_state = "firing_pin_explorer"
	fail_message = "firearms permit check failed!</span>"

// This checks that the user isn't on the station Z-level.
/obj/item/firing_pin/permit_pin/pin_auth(mob/living/user)
	var/turf/station_check = get_turf(user)

	if(obj_flags & EMAGGED)
		return TRUE

	if(GLOB.permit_pin_unrestricted)
		return TRUE

	var/obj/item/card/id/the_id = user.get_idcard()

	if(!the_id && is_station_level(station_check.z))
		return FALSE

	if(!is_station_level(station_check.z) || (ACCESS_WEAPONS in the_id.GetAccess()))
		return TRUE


/obj/item/firing_pin
	var/can_remove = TRUE

/obj/item/firing_pin/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "firing pin unlocked!")
	obj_flags |= EMAGGED
	can_remove = TRUE
	return TRUE

/obj/item/clothing/glasses/hud/gun_permit
	name = "permit HUD"
	desc = "A heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	icon = 'monkestation/code/modules/blueshift/icons/hud_goggles.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/hud_goggles_worn.dmi'
	icon_state = "permithud"
	hud_type = DATA_HUD_PERMIT

/obj/item/clothing/glasses/hud/gun_permit/sunglasses
	name = "permit HUD sunglasses"
	desc = "A pair of sunglasses with a heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/datum/design/permit_hud
	name = "Gun Permit HUD glasses"
	desc = "A heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	id = "permit_glasses"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/clothing/glasses/hud/gun_permit
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/proc/toggle_permit_pins()
	GLOB.permit_pin_unrestricted = !GLOB.permit_pin_unrestricted
	minor_announce("Permit-locked firing pins have now had their locks [GLOB.permit_pin_unrestricted ? "removed" : "reinstated"].", "Weapons Systems Update:")
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("permit-locked pins", GLOB.permit_pin_unrestricted ? "unlocked" : "locked"))

/obj/item/sensor_device
	name = "handheld crew monitor" //Thanks to Gun Hog for the name! //added the word vitals :v
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_med"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_CREW * 5
	custom_premium_price = PAYCHECK_CREW * 6

/obj/item/sensor_device/attack_self(mob/user)
	GLOB.crewmonitor.show(user,src) //Proc already exists, just had to call it

/obj/item/sensor_device/security
	name = "security handheld crew monitor"
	desc = "A unique model of the handheld crew monitor, configured to only monitor security's vitals."
	icon_state = "scanner_sec"

/obj/item/sensor_device/security/attack_self(mob/user)
	GLOB.crewmonitor_security.show(user,src)

/obj/item/sensor_device/command
	name = "specialized handheld crew monitor"
	desc = "A specialized model of handheld crew monitor that seems to have been customized for the purpose of protecting high rank Nanotrasen employees."
	icon_state = "scanner_command"

/obj/item/sensor_device/command/attack_self(mob/user)
	GLOB.crewmonitor_command.show(user,src)

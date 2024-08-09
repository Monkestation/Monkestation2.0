#define MACHINE_CONVERSION_TIME 30 SECONDS
//an item that will change the ownership of a gang machine to that of the user's gang, also note that THIS WORKS ON OBJECTIVE MACHINES AS WELL
//RANDOM WAREHOUSE WEAPON
//SUPER CLAIM AREA OBJECTIVE
/obj/item/gang_device/machine_converter
	name = "suspicious device"
	desc = "A small device with what looks to be a port for interfacing with machines."
	icon_state = "experiscanner"
	gang_examine = "A device that can be attached to a machine owned by another gang to convert it's ownership to your own."

/obj/item/gang_device/machine_converter/afterattack(obj/machinery/gang_machine/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(user)
	if(!antag_datum || !antag_datum.gang_team)
		balloon_alert(user, "you can't figure out how to use \the [src].")
		return

	if(!istype(target))
		balloon_alert(user, "\the [src] wont work on \the [target].")
		return

	if(antag_datum.gang_team == target.owner)
		balloon_alert(user, "your gang already controls \the [target].")
		return

	if(!do_after(user, MACHINE_CONVERSION_TIME, target))
		return

	balloon_alert(user, "ownership transfer successful.")
	target.owner = antag_datum.gang_team
	qdel(src)

#undef MACHINE_CONVERSION_TIME

/obj/item/gang_device/communicator_upgrade
	name = "communicator ugrade"
	desc = "A strange device with what looks to be a radio transmitter attached."
	icon_state = "trapdoor_pressed"
	gang_examine = "Apply to something that contains a gang implant to upgrade the implant with a communicator for your gang."

/obj/item/gang_device/communicator_upgrade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/item/implant/uplink/gang/implant = locate(/obj/item/implant/uplink/gang) in target.contents
	if(!implant)
		return ..()

	if(implant.communicate)
		to_chat(user, span_notice("\The [implant] already has a communicator."))
		return ..()

	implant.add_communicator()
	qdel(src)
	return

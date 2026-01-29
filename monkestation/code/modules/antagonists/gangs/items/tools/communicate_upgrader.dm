/obj/item/gang_device/communicator_upgrade
	name = "communicator ugrade"
	desc = "A strange device with what looks to be a radio transmitter attached."
	icon_state = "trapdoor_pressed"
	gang_examine = "Apply to something that contains a gang implant to upgrade the implant with a communicator for your gang."

/obj/item/gang_device/communicator_upgrade/afterattack(mob/living/target, mob/user, list/modifiers, list/attack_modifiers) //could maybe move this to earlier in the attack chain
	if(!IS_GANGMEMBER(user))
		return ..()

	var/obj/item/implant/uplink/gang/implant
	if(!ismob(target))
		implant = locate(/obj/item/implant/uplink/gang) in target.contents //this works on both implanters and implant cases
		if(!implant)
			return ..()
		if(implant.has_communicator)
			to_chat(user, span_notice("\The [implant] already has a communicator."))
			return ..()
		implant.has_communicator = TRUE
		qdel(src)
		return

	var/datum/antagonist/gang_member/member_target = IS_GANGMEMBER(target)
	if(!member_target || member_target.communicate) //both silently fail so you cant tell which it is
		return

	implant = locate(/obj/item/implant/uplink/gang) in target.implants
	//you are able to use this to find members of other gangs but seeing as it both costs TC to give them a free item and very clearly outs you I think its reasonable
	if(!implant?.add_communicator(member_target)) //check for redundant logic
		return
	to_chat(user, span_notice("You give [target] a communicator upgrade"))
	qdel(src)
	return

/obj/item/gang_device/promoter
	name = "gang promoter"
	desc = "A single use device able to improve a gang implant's uplink connection."
	icon_state = "multitool_circuit_flick"
	gang_examine = "This device may be used to promote someone to a %RANK%."
	///What rank do we promote people to
	var/datum/antagonist/gang_member/promoted_to = /datum/antagonist/gang_member/lieutenant

/obj/item/gang_device/promoter/Initialize(mapload)
	gang_examine = replacetext(gang_examine, "%RANK%", initial(promoted_to.name))
	. = ..()

/obj/item/gang_device/promoter/afterattack(mob/living/target, mob/user, proximity_flag, click_parameters)
	if(!isliving(target))
		return ..()

	var/datum/antagonist/gang_member/user_datum = IS_GANGMEMBER(user)
	var/datum/antagonist/gang_member/target_datum = IS_GANGMEMBER(target)
	if(!user_datum || user_datum.rank < GANG_RANK_LIEUTENANT || !target_datum || !target_datum.rank < initial(promoted_to.rank))
		to_chat(user, span_notice("You cannot promote [target]"))
		return ..()

	var/obj/item/implant/uplink/gang/implant = locate(/obj/item/implant/uplink/gang) in target.implants
	implant?.add_communicator()
	target_datum.change_rank(promoted_to)
	qdel(src)
	return

/obj/item/gang_device/promoter/boss
	promoted_to = /datum/antagonist/gang_member/boss

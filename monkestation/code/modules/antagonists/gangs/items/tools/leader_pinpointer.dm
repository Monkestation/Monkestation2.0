/obj/item/pinpointer/gang_leader
	icon_state = "pinpointer_syndicate"
	///The gang this pinpointer is linked to
	var/datum/team/gang/linked_to

/obj/item/pinpointer/gang_leader/attack_self(mob/living/user)
	if(linked_to && IS_IN_GANG(user, linked_to))
		var/list/trackable_members = linked_to.member_datums_by_rank[GANG_RANK_LIEUTENANT] + linked_to.member_datums_by_rank[GANG_RANK_BOSS]
		for(var/datum/antagonist/gang_member/member in trackable_members)
			trackable_members -= member
			var/datum/mind/owner = member.owner
			if(owner.current)
				trackable_members += owner.current
		if(length(trackable_members))
			target = tgui_input_list(user, "Select who to track", "pinpointer", trackable_members)
	return ..()

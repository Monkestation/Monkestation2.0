/obj/item/pinpointer/gang
	icon_state = "pinpointer_syndicate"
	///Description given to gang members
	var/gang_desc = ""

/obj/item/pinpointer/gang/Initialize(mapload)
	. = ..()
	if(gang_desc)
		AddElement(/datum/element/extra_examine/gang, span_syndradio(gang_desc))

/obj/item/pinpointer/gang/leader
	///The gang this pinpointer is linked to
	var/datum/team/gang/linked_to

/obj/item/pinpointer/gang/leader/attack_self(mob/living/user)
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

/obj/item/pinpointer/gang/tag
	gang_desc = "A pinpointer used to track gang tags within an area."

/obj/item/pinpointer/gang/tag/attack_self(mob/living/user)
	if(active)
		return ..()

	var/area/our_area = get_area(user)
	var/obj/effect/decal/cleanable/crayon/gang/area_tag = SSgangs.gang_tags_by_area?[our_area]
	if(area_tag)
		target = get_turf(area_tag)
		user.balloon_alert(user, "now tracking the tag for [our_area]")
	else
		user.balloon_alert(user, "no gang tags found for [our_area]")
		target = null
	return ..()

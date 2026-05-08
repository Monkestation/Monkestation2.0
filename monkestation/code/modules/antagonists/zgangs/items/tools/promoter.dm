/obj/item/gang_device/promoter
	name = "gang promoter"
	desc = "A single use device able to improve a gang implant's uplink connection."
	icon_state = "multitool_circuit_flick"
	gang_examine = "This device may be used to promote someone to a %RANK%."
	///What rank do we promote people to
	var/datum/antagonist/gang_member/promoted_to = /datum/antagonist/gang_member/lieutenant
	///Do we force promotion
	var/debug = FALSE

/obj/item/gang_device/promoter/Initialize(mapload)
	gang_examine = replacetext(gang_examine, "%RANK%", initial(promoted_to.name))
	return ..()

/obj/item/gang_device/promoter/afterattack(mob/living/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target))
		return ..()

	var/datum/antagonist/gang_member/user_datum = IS_GANGMEMBER(user)
	if(!user_datum)
		return ..()

	var/datum/antagonist/gang_member/target_datum = IS_GANGMEMBER(target)
	if(!target_datum)
		return ..()

	if(!debug && (user_datum.rank < GANG_RANK_LIEUTENANT || user_datum.gang_team != target_datum.gang_team || target_datum.rank >= initial(promoted_to.rank)))
		to_chat(user, span_notice("You cannot promote [target]"))
		return ..()

	if(!debug && !extra_checks(target_datum, user_datum))
		return ..()

	target_datum.change_rank(promoted_to)
	qdel(src)
	return

/obj/item/gang_device/promoter/proc/extra_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	var/list/lieutenant_list = target.gang_team.member_datums_by_rank[GANG_RANK_LIEUTENANT]
	if(length(lieutenant_list) >= MAX_LIEUTENANTS)
		var/real_lieutenants = 0
		for(var/datum/antagonist/gang_member/lieutenant_datum in lieutenant_list)
			if(lieutenant_datum.owner?.current)
				real_lieutenants++
		if(real_lieutenants >= MAX_LIEUTENANTS)
			balloon_alert(user.owner.current, "you already have the maximum amount of lieutenants")
			return FALSE
	return TRUE

/obj/item/gang_device/promoter/boss
	promoted_to = /datum/antagonist/gang_member/boss

/obj/item/gang_device/promoter/boss/extra_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(!MEETS_GANG_RANK(target, GANG_RANK_LIEUTENANT))
		balloon_alert(user.owner.current, "[target.owner.current] must be a lieutenant to be promoted")
		return FALSE

	var/list/boss_list = target.gang_team.member_datums_by_rank[GANG_RANK_BOSS]
	if(length(boss_list))
		for(var/datum/antagonist/gang_member/boss_datum in boss_list)
			if(boss_datum.owner?.current)
				balloon_alert(user.owner.current, "you still have a living boss")
				return FALSE
	return TRUE

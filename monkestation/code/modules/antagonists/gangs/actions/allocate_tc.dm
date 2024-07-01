/datum/action/innate/allocate_gang_tc
	name = "Allocate Telecrystals"
	desc = "Allocate the free flowing telecrystals within your gang's network to yourself and your lieutenants."
	button_icon = 'icons/obj/telescience.dmi'
	button_icon_state = "telecrystal_3"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/allocate_gang_tc/Activate()
	if(!IsAvailable())
		return

	var/datum/antagonist/gang_member/antag_owner = IS_GANGMEMBER(owner)
	if(!antag_owner)
		to_chat(owner, "You are not a gangmember and should not have this!")
		CRASH("[src] calling Activate() with an owner\[[owner]\] who lacks a gangmember antag datum.")

	if(!antag_owner.gang_team)
		to_chat(owner, "You are not in a gang and should not have this!")
		CRASH("[src] calling Activate() with an owner\[[owner]\] who is not in a gang.")

	var/truncated_tc_amount = trunc(antag_owner.gang_team.unallocated_tc)
	if(!truncated_tc_amount)
		to_chat(owner, span_notice("Your gang does not have any unallocated TC."))
		return

	var/list/ranking_member_handlers = list()
	var/list/member_datums_by_rank = antag_owner.gang_team.member_datums_by_rank //this is actualy slightly cheaper(but I actually just dont want the next line to be too long)
	for(var/datum/antagonist/gang_member/antag_datum in member_datums_by_rank["[GANG_RANK_BOSS]"] + member_datums_by_rank["[GANG_RANK_LIEUTENANT]"])
		if(!antag_datum.owner)
			continue

		ranking_member_handlers[antag_datum.owner] = antag_datum.handler

	if(!length(ranking_member_handlers))
		CRASH("[src] calling Activate() without ranking_member_handlers length")

	var/datum/uplink_handler/gang/chosen_handler = tgui_input_list(owner, "Who would you like to allocate to?", "Allocate TC", ranking_member_handlers)
	if(!chosen_handler)
		return

	chosen_handler = ranking_member_handlers[chosen_handler]
	var/chosen_amount = tgui_input_number(owner, "How much would you like to allocate?", "Available TC: [truncated_tc_amount]", 0, truncated_tc_amount, 0, round_value = TRUE)
	if(!chosen_amount || truncated_tc_amount < chosen_amount)
		return

	chosen_handler.telecrystals += chosen_amount
	chosen_handler.on_update()
	antag_owner.gang_team.unallocated_tc -= chosen_amount

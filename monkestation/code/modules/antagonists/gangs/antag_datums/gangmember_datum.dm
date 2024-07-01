/datum/antagonist/gang_member
	name = "\improper Syndicate gang member"
	roundend_category = "gangs"
	job_rank = ROLE_GANG_MEMBER
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	antagpanel_category = "Gang"
	antag_hud_name = "hud_gangster"
	ui_name = "AntagInfoGang"
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new()
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

/datum/antagonist/gang_member/on_gain()
	var/list/member_list = gang_team.member_datums_by_rank["[rank]"]
	if(!member_list)
		member_list = list()
		gang_team.member_datums_by_rank["[rank]"] = member_list
	member_list += src

	objectives += gang_team.objectives
	handler.can_take_objectives = !!rank //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()

	hud_keys = gang_team.gang_tag
	if(owner?.current)
		add_team_hud(owner.current, /datum/antagonist/gang_member)
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/familieswork.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

//might need to handle body transfer
/datum/antagonist/gang_member/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner?.current?.faction += "[REF(gang_team)]"

/datum/antagonist/gang_member/on_removal(obj/item/implant/uplink/gang/implant)
	handler = null
	if(!implant)
		implant = locate() in owner?.current?.implants

	. = ..()
	gang_team.member_datums_by_rank["[rank]"] -= src
	if(implant)
		UnregisterSignal(implant, list(COMSIG_IMPLANT_REMOVED, COMSIG_PRE_IMPLANT_REMOVED))
		gang_team.implants -= implant

/datum/antagonist/gang_member/remove_innate_effects(mob/living/mob_override)
	. = ..()
	owner?.current?.faction -= "[REF(gang_team)]"

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum)
	if(ispath(new_datum))
		new_datum = new new_datum()

	silent = TRUE
	new_datum.handler = handler
	var/obj/item/implant/uplink/gang/implant = locate() in owner?.current?.implants
	var/datum/mind/owner_ref = owner //we need to keep a temp ref of this to use after on_removal()
	on_removal(implant)
	owner_ref?.add_antag_datum(new_datum, gang_team)
	if(implant)
		new_datum.RegisterSignal(implant, COMSIG_PRE_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_pre_implant_removal))
		new_datum.RegisterSignal(implant, COMSIG_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_implant_removal))
		if(MEETS_GANG_RANK(new_datum, GANG_RANK_LIEUTENANT))
			implant.add_communicator()

///Block implant removal if we are a lieutenant or higher
/datum/antagonist/gang_member/proc/handle_pre_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	if(rank >= GANG_RANK_LIEUTENANT)
		return COMPONENT_STOP_IMPLANT_REMOVAL

/datum/antagonist/gang_member/proc/handle_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	on_removal(source)

/datum/antagonist/gang_member/boss
	name = "\improper Syndicate Gang Boss"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_boss"
	rank = GANG_RANK_BOSS
	///Our TC allocation ability
	var/datum/action/innate/allocate_gang_tc/allocate

/datum/antagonist/gang_member/boss/on_gain()
	allocate = new
	return ..()

/datum/antagonist/gang_member/boss/on_removal(obj/item/implant/uplink/gang/implant)
	. = ..()
	if(!QDELETED(allocate))
		QDEL_NULL(allocate)

/datum/antagonist/gang_member/boss/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(owner?.current)
		allocate.Grant(owner.current)

/datum/antagonist/gang_member/boss/remove_innate_effects(mob/living/mob_override)
	. = ..()
	if(owner?.current)
		allocate.Remove(owner.current)

/datum/antagonist/gang_member/lieutenant
	name = "\improper Syndicate Gang Lieutenant"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_hud_name = "gang_lieutenant"
	rank = GANG_RANK_LIEUTENANT

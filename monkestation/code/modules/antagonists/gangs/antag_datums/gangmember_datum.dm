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
	///Typepath of item to give on_gain(), set to null to give nothing
	var/given_gear_type = /obj/item/toy/crayon/spraycan/gang

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
	if(!handler.primary_objectives)
		handler.primary_objectives = objectives.Copy()
	else
		handler.primary_objectives |= objectives
	handler.can_take_objectives = !!rank //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()

	hud_keys = gang_team.gang_tag
	if(owner?.current)
		add_team_hud(owner.current, /datum/antagonist/gang_member)
		if(given_gear_type)
			var/obj/item/given_item = new given_gear_type(get_turf(owner.current))
			var/mob/living/carbon/carbon_current = (iscarbon(owner.current) ? owner.current : null)
			if(!carbon_current?.equip_in_one_of_slots(given_item, list("backpack" = ITEM_SLOT_BACKPACK)))
				owner.current.put_in_hands(given_item)
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

/datum/antagonist/gang_member/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	var/static/list/implant_types_to_give
	if(!implant_types_to_give)
		implant_types_to_give = list()
		for(var/obj/item/implant/uplink/gang/implant as anything in typesof(/obj/item/implant/uplink/gang))
			implant_types_to_give[initial(implant.antag_type)] = implant

	var/datum/team/gang/selected_gang = tgui_input_list(admin, "What gang would you like them to be a part of?", "Select Gang", GLOB.all_gangs_by_tag + "New Gang")
	var/created_type = implant_types_to_give[src.type]
	var/obj/item/implant/uplink/gang/given_implant = new created_type(new_owner.current)
	given_implant.give_gear = TRUE
	given_implant.implant(new_owner.current, force = TRUE, forced_gang = (istype(selected_gang, /datum/team/gang)))

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
	var/active_length = length(handler.active_objectives)
	while(active_length && handler.maximum_active_objectives < active_length) //our handler is the same so we can just access it locally
		var/datum/traitor_objective/objective = handler.active_objectives[active_length]
		objective.fail_objective() //penalty is unset so it will just count as invalid
		handler.complete_objective(objective)
		active_length = length(handler.active_objectives)

	var/potential_length = length(handler.potential_objectives)
	while(potential_length && handler.maximum_potential_objectives < potential_length)
		var/datum/traitor_objective/objective = handler.potential_objectives[potential_length]
		objective.handle_cleanup()
		potential_length = length(handler.potential_objectives)

	handler.on_update() //im gonna say its cheaper to just always run this rather than set up some kind of janky check for it
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
	given_gear_type = /obj/item/storage/box/syndicate/gang_boss_kit
	///Our TC allocation ability
	var/datum/action/innate/allocate_gang_tc/allocate = new
	///Do we give them the starting equipment box
	var/give_equipment_box = FALSE

/datum/antagonist/gang_member/boss/on_removal(obj/item/implant/uplink/gang/implant)
	if(!QDELETED(allocate))
		QDEL_NULL(allocate)
	return ..()

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

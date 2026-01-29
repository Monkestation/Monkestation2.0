#define ADD_UPLINK_COMPONENT AddComponent(/datum/component/uplink, owner = owner.key, lockable = TRUE, enabled = FALSE, uplink_handler_override = handler)

/datum/antagonist/gang_member
	name = "\improper Syndicate Gang Member"
	roundend_category = "gangs"
	job_rank = ROLE_GANG_MEMBER
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5 //TODO: make hyjacking give rep to the team that does it
	antagpanel_category = "Gang"
	antag_hud_name = "hud_gangster"
	ui_name = "AntagInfoGang"
	stinger_sound = 'sound/ambience/antag/familieswork.ogg'
	antag_count_points = 5 //mini traitor
	base_type = /datum/antagonist/gang_member
	preview_outfit = /datum/outfit/gang_boss_preview
	///Ref to our team
	var/datum/team/gang/gang_team
	///What is our rank
	var/rank = GANG_RANK_MEMBER
	///Ref to our uplink handler
	var/datum/uplink_handler/gang/handler
	///Typepath of item to give on_gain(), set to null to give nothing
	var/given_gear_type = /obj/item/toy/crayon/spraycan/gang
	///Ref to our gang communicator action, if we have one
	var/datum/action/innate/gang_communicate/communicate //make this work correctly
	///Are we currently changing rank
	var/changing_rank = FALSE
	///A weakref to the implant we are from
	var/datum/weakref/implant_source

/datum/antagonist/gang_member/New()
	. = ..()
	if(rank >= GANG_RANK_LIEUTENANT)
		set_communicate_source()

/datum/antagonist/gang_member/create_team(datum/team/team)
	if(!team)
		gang_team = new()
		return
	gang_team = team

/datum/antagonist/gang_member/get_team()
	return gang_team

/datum/antagonist/gang_member/on_gain()
	var/list/member_list = gang_team.member_datums_by_rank[rank]
	if(!member_list)
		member_list = list()
		gang_team.member_datums_by_rank[rank] = member_list
	member_list += src

	objectives += gang_team.objectives
	handler = gang_team.get_specific_handler(owner)

	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_current = owner.current
		handler.assigned_role = owner.assigned_role?.title //might not want to have these
		handler.assigned_species = carbon_current.dna?.species?.id

	if(!implant_source?.resolve() && !GetComponent(/datum/component/uplink))
		ADD_UPLINK_COMPONENT

	if(!handler.primary_objectives)
		handler.primary_objectives = objectives.Copy()
	else
		handler.primary_objectives |= objectives

	check_handler_values()

	hud_keys = gang_team.gang_tag
	if(owner.current)
		if(given_gear_type)
			var/obj/item/given_item = new given_gear_type(get_turf(owner.current))
			var/mob/living/carbon/carbon_current = (iscarbon(owner.current) ? owner.current : null)
			if(!carbon_current?.equip_in_one_of_slots(given_item, list("backpack" = ITEM_SLOT_BACKPACK)))
				owner.current.put_in_hands(given_item)
	return ..()

/datum/antagonist/gang_member/on_body_transfer(mob/living/old_body, mob/living/new_body)
	var/obj/item/implant/uplink/gang/old_implant = implant_source?.resolve()
	if(!old_implant)
		return ..()

	old_implant.removed(old_body, special = TRUE, forced = TRUE)
	old_implant.implant(new_body)
	return ..()

//might need to handle body transfer
/datum/antagonist/gang_member/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		current.faction += "[REF(gang_team)]"
		communicate?.Grant(current)
		add_team_hud(current, /datum/antagonist/gang_member)

/datum/antagonist/gang_member/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		current.faction -= "[REF(gang_team)]"
		communicate?.Remove(current)

/datum/antagonist/gang_member/on_removal(obj/item/implant/uplink/gang/removed_implant=implant_source?.resolve(),should_remove_implant=(rank<GANG_RANK_LIEUTENANT&&!changing_rank))
	handler = null
	UnregisterSignal(removed_implant, COMSIG_IMPLANT_REMOVED)
	. = ..()
	if(!QDELETED(removed_implant) && should_remove_implant)
		removed_implant.removed(removed_implant.imp_in, silent = TRUE, forced = TRUE)
		qdel(removed_implant)
	gang_team.member_datums_by_rank[rank] -= src
	if(communicate?.source_rank < GANG_RANK_LIEUTENANT)
		QDEL_NULL(communicate)

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
	given_implant.implant(new_owner.current, force = TRUE, forced_gang = GLOB.all_gangs_by_tag[selected_gang])

/datum/antagonist/gang_member/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return

	return !HAS_TRAIT(new_owner, TRAIT_UNCONVERTABLE)

/datum/antagonist/gang_member/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)
	final_icon.Blend(make_henchmen_icon("CIA"), ICON_OVERLAY, world.icon_size / 4, 0)
	final_icon.Blend(make_henchmen_icon("Business Hair"), ICON_OVERLAY, -world.icon_size / 4, 0)
	return finish_preview_icon(final_icon)

/datum/antagonist/gang_member/proc/make_henchmen_icon(hairstyle, outfit = /datum/outfit/gang_lieutenant_preview)
	var/mob/living/carbon/human/dummy/consistent/henchman = new
	henchman.set_hairstyle(hairstyle, update = TRUE)

	var/icon/henchman_icon = render_preview_outfit(outfit, henchman)
	henchman_icon.ChangeOpacity(0.8)

	return henchman_icon

///do the logic for a new implant depending on our rank
/datum/antagonist/gang_member/proc/handle_new_implant(obj/item/implant/uplink/gang/handled)
	if(QDELETED(handled))
		CRASH("handle_new_implant() being passed a qdeling implant")

	if(rank < GANG_RANK_LIEUTENANT)
		RegisterSignal(handled, COMSIG_IMPLANT_REMOVED, PROC_REF(on_implant_removal))
		implant_source = WEAKREF(handled)
	else
		if(!GetComponent(/datum/component/uplink))
			ADD_UPLINK_COMPONENT
		qdel(handled)

///Set the values in our handler to be correct for our rank
/datum/antagonist/gang_member/proc/check_handler_values() //could maybe move this onto the handlers themselves
	handler.can_take_objectives = !!rank //return it as a bool
	handler.maximum_active_objectives = 1 * rank //this actually just works, but if you for some reason ever mess with ranks this will break
	handler.maximum_potential_objectives = 3 * rank
	if(handler.maximum_potential_objectives)
		handler.generate_objectives()

	handler.on_update()

///Change our datum type to a different one
/datum/antagonist/gang_member/proc/change_rank(datum/antagonist/gang_member/new_datum) //might want to make a specific proc for demotion
	if(ispath(new_datum))
		new_datum = new new_datum()

	silent = TRUE
	changing_rank = TRUE
	var/datum/uplink_handler/handler_ref = handler
	var/datum/component/uplink/uplink_component
	if(rank >= GANG_RANK_LIEUTENANT)
		uplink_component = GetComponent(/datum/component/uplink)
	else
		uplink_component = astype(implant_source?.resolve(), /datum)?.GetComponent(/datum/component/uplink)

	if(MEETS_GANG_RANK(new_datum, GANG_RANK_LIEUTENANT))
		new_datum.TakeComponent(uplink_component)
		new_datum.set_communicate_source(communicate)
		communicate = null

	var/obj/item/implant/uplink/gang/our_implant = implant_source?.resolve()
	if(our_implant)
		new_datum.handle_new_implant(our_implant)

	var/datum/mind/owner_ref = owner //we need to keep a temp ref of this to use after on_removal()
	on_removal()
	owner_ref?.add_antag_datum(new_datum, gang_team)
	var/active_length = length(handler_ref.active_objectives)
	while(active_length && handler_ref.maximum_active_objectives < active_length)
		var/datum/traitor_objective/objective = handler_ref.active_objectives[active_length]
		objective.fail_objective() //penalty is unset so it will just count as invalid
		handler_ref.complete_objective(objective)
		active_length = length(handler_ref.active_objectives)

	var/potential_length = length(handler_ref.potential_objectives)
	while(potential_length && handler_ref.maximum_potential_objectives < potential_length)
		var/datum/traitor_objective/objective = handler_ref.potential_objectives[potential_length]
		objective.handle_cleanup()
		potential_length = length(handler_ref.potential_objectives)

	handler_ref.on_update()

///Create our communicate action if we dont have one then set its source
/datum/antagonist/gang_member/proc/set_communicate_source(datum/action/innate/gang_communicate/commune, source = rank)
	if(!communicate)
		communicate = commune || new
		communicate.Grant(owner?.current) //if owner is the same or null then Grant() just returns, so this is safe
	communicate.source_rank = source

/datum/antagonist/gang_member/proc/on_implant_removal(datum/source, mob/living/mob_source, silent, special)
	SIGNAL_HANDLER
	if(special || changing_rank)
		return

	on_removal(source, FALSE)

/datum/antagonist/gang_member/ui_static_data(mob/user)
	var/list/data = ..()
	data["gang_name"] = gang_team.name
	return data

/datum/antagonist/gang_member/lieutenant
	name = "\improper Syndicate Gang Lieutenant"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_count_points = 8
	antag_hud_name = "gang_lieutenant"
	rank = GANG_RANK_LIEUTENANT

/datum/antagonist/gang_member/boss
	name = "\improper Syndicate Gang Boss"
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	show_to_ghosts = TRUE
	antag_count_points = 12
	antag_hud_name = "gang_boss"
	rank = GANG_RANK_BOSS
	given_gear_type = /obj/item/storage/box/syndicate/gang_boss_kit
	///Our TC allocation ability
	var/datum/action/innate/allocate_gang_tc/allocate = new

/datum/antagonist/gang_member/boss/on_removal(obj/item/implant/uplink/gang/implant)
	QDEL_NULL(allocate)
	return ..()

/datum/antagonist/gang_member/boss/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		allocate.Grant(current)

/datum/antagonist/gang_member/boss/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner?.current
	if(current)
		allocate?.Remove(current)

#undef ADD_UPLINK_COMPONENT

/datum/outfit/gang_boss_preview
	head = /obj/item/clothing/head/fedora/white
	glasses = /obj/item/clothing/glasses/sunglasses/big
	uniform = /obj/item/clothing/under/suit/white
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/cowboy/white
	r_hand = /obj/item/storage/briefcase/secure/empty
	//l_hand = /obj/item/storage/canesword/syndicate sadly breaks the preview icon, for some reason

/datum/outfit/gang_lieutenant_preview
	head = /obj/item/clothing/head/fedora
	uniform = /obj/item/clothing/under/suit/checkered
	r_hand = /obj/item/gun/ballistic/automatic/tommygun
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/gang_member_preview
	head = /obj/item/clothing/head/henchmen_hat/traitor
	uniform = /obj/item/clothing/under/color/black
	gloves = /obj/item/clothing/gloves/color/light_brown
	suit = /obj/item/clothing/suit/jacket/henchmen_coat/traitor
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/switchblade/extended
	r_hand = /obj/item/gun/ballistic/automatic/mini_uzi

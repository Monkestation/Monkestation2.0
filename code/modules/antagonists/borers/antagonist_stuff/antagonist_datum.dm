/datum/antagonist/cortical_borer
	name = "Cortical Borer"
	job_rank = ROLE_CORTICAL_BORER
	roundend_category = "enslaved cortical borers" // May look a bit confusing, but these borers are not a part of a hivemind. So they are probably enslaved
	antagpanel_category = "Cortical Borers"
	ui_name = "AntagInfoBorer"
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE_HUMANITY
	antag_count_points = 0.5 // While a single borer can be helpful, if you have a lot on station things are bound to get chaotic and a few diveworms.
	/// Borer mob type, used for antag token spawns.
	var/borer_mob_type = /mob/living/basic/cortical_borer/neutered
	/// The hivemind this borer belongs to, can be null
	var/datum/team/cortical_borers/team

/datum/antagonist/cortical_borer/Destroy(force)
	if(team)
		team.remove_member(owner)
		team = null
	return ..()

// Lets the borers see who is a willing host
/datum/antagonist/cortical_borer/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)

/datum/antagonist/cortical_borer/antag_token(datum/mind/hosts_mind, mob/spender)
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		if(QDELETED(temp_vent))
			continue
		if(!is_station_level(temp_vent.loc.z) || temp_vent.welded)
			continue
		var/area/vent_area = get_area(temp_vent)
		if(!(vent_area.type in GLOB.the_station_areas))
			continue
		var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
		if(!temp_vent_parent)
			continue // No parent vent
		// Stops Borers getting stuck in small networks.
		// See: Security, Virology
		if(length(temp_vent_parent.other_atmos_machines) > 20)
			vents += temp_vent

	if(!length(vents))
		message_admins(span_adminnotice("[spender] ([ckey(spender.key)]) tried spawning in as a borer, but no suitable vents were found!"))
		return MAP_ERROR

	if(isliving(spender))
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 1 SECONDS)

	var/vent = pick(vents)
	var/mob/living/basic/cortical_borer/spawned_cb = new borer_mob_type(get_turf(vent))
	spawned_cb.PossessByPlayer(spender.ckey)
	var/datum/antagonist/cortical_borer/antag = spawned_cb.mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(borer_mob_type == /mob/living/basic/cortical_borer/neutered)
		var/list/objectives_to_give = list(
			/datum/objective/borer/learn_chemicals/selfish,
			/datum/objective/borer/dissect_bodies,
		)
		for(var/datum/objective/borer/objective as anything in objectives_to_give)
			objective = new objective()
			objective.owner = spawned_cb.mind
			objective.update_explanation_text()
			antag.objectives += objective
		antag.update_static_data_for_all_viewers()
	else
		var/datum/team/cortical_borers/team = new()
		team.create_objectives()
		team.add_member(spawned_cb.mind, antag)

	spawned_cb.move_into_vent(vent)
	notify_ghosts(
		"Someone has become a borer due to spending an antag token ([spawned_cb])!",
		source = spawned_cb,
		action = NOTIFY_ORBIT,
		header = "Something's Interesting!",
	)
	message_admins("[ADMIN_LOOKUPFLW(spawned_cb)] has been made into a borer by using an antag token.")
	to_chat(spawned_cb, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))

/datum/antagonist/cortical_borer/get_team()
	return team

/datum/antagonist/cortical_borer/get_preview_icon()
	var/icon/preview = icon('icons/mob/borer/borer.dmi', "brainslug")
	preview.Scale(115, 115)
	preview.Shift(WEST, 8)
	preview.Crop(1, 1, ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return preview

/datum/antagonist/cortical_borer/hivemind // Why yes this is specifically here only for token borers, why do you ask?
	borer_mob_type = /mob/living/basic/cortical_borer/empowered

/datum/antagonist/cortical_borer/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/cortical_borer/cortical_owner = owner.current
	for(var/datum/action/cooldown/borer/ability as anything in cortical_owner.known_abilities)
		var/list/ability_data = list()

		ability_data["ability_name"] = initial(ability.name)
		ability_data["ability_explanation"] = initial(ability.ability_explanation)
		ability_data["ability_icon"] = initial(ability.button_icon)
		ability_data["ability_icon_state"] = initial(ability.button_icon_state)

		data["ability"] += list(ability_data)

	return data + ..()

/datum/antagonist/cortical_borer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/borer_icons),
	)

/datum/antagonist/brother
	name = "\improper Brother"
	antagpanel_category = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = ROLE_BROTHER
	antag_hud_name = "brother"
	hijack_speed = 0.5
	ui_name = "AntagInfoBrother"
	suicide_cry = "FOR MY BROTHER!!"
	antag_moodlet = /datum/mood_event/focused
	hardcore_random_bonus = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_TEAM // monkestation addition
	var/datum/action/bb/comms/comms_action
	var/datum/action/bb/gear/gear_action
	VAR_PRIVATE/datum/team/brother_team/team

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team
	set_hud_keys(REF(new_team))

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	objectives |= team.objectives
	owner.special_role = special_role
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	owner.special_role = null
	return ..()

// Apply team-specific antag HUD.
/datum/antagonist/brother/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(QDELETED(comms_action))
		comms_action = new(src)
	if(QDELETED(gear_action) && !team.summoned_gear)
		gear_action = new(src)
	var/mob/living/target = mob_override || owner.current
	comms_action.Grant(target)
	gear_action?.Grant(target)
	add_team_hud(target, /datum/antagonist/brother, REF(team))

/datum/antagonist/brother/remove_innate_effects(mob/living/mob_override)
	. = ..()
	comms_action?.Remove(mob_override || owner.current)
	QDEL_NULL(comms_action)
	gear_action?.Remove(mob_override || owner.current)
	QDEL_NULL(gear_action)

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

// monkestation start: refactor to use [get_base_preview_icon] for better midround polling images
/datum/antagonist/brother/get_base_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new
	var/datum/color_palette/generic_colors/located = brother1.dna.color_palettes[/datum/color_palette/generic_colors]

	located.ethereal_color = GLOB.color_list_ethereal["Faint Red"]
	brother1.set_species(/datum/species/ethereal)

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	var/icon/blood1_icon = icon('icons/effects/blood.dmi', "maskblood")
	blood1_icon.Blend(COLOR_BLOOD, ICON_MULTIPLY)
	brother1_icon.Blend(blood1_icon, ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist/consistent, brother2)
	var/icon/blood2_icon = icon('icons/effects/blood.dmi', "uniformblood")
	blood2_icon.Blend(COLOR_BLOOD, ICON_MULTIPLY)
	brother2_icon.Blend(blood2_icon, ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return final_icon

/datum/antagonist/brother/get_preview_icon()
	return finish_preview_icon(get_base_preview_icon())
// monkestation end

/datum/antagonist/brother/proc/get_brother_names(add_span = FALSE)
	var/list/names = list()
	for(var/datum/mind/brother as anything in team.members - owner)
		names += add_span ? span_name(brother.name) : brother.name
	return english_list(names)

/datum/antagonist/brother/greet()
	to_chat(owner.current, span_alertsyndie("You are the [owner.special_role]."))
	owner.announce_objectives()

/datum/antagonist/brother/proc/finalize_brother()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	team.update_name()

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	var/datum/team/brother_team/team = new
	team.add_member(new_owner)
	team.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother, team)
	team.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into a blood brother.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into a blood brother.")

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/brother/antag_token(datum/mind/hosts_mind, mob/spender)
	var/datum/team/brother_team/team = new
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		var/datum/mind/new_mind = new_mob.mind
		team.add_member(new_mind)
		team.forge_brother_objectives()
		new_mind.add_antag_datum(/datum/antagonist/brother, team)
	else
		team.add_member(hosts_mind)
		team.forge_brother_objectives()
		hosts_mind.add_antag_datum(/datum/antagonist/brother, team)

/datum/antagonist/brother/proc/communicate(message)
	if(!istext(message) || !length(message) || QDELETED(owner) || QDELETED(team))
		return
	owner.current.log_talk(html_decode(message), LOG_SAY, tag = "blood brother")
	var/formatted_msg = "<span class='[team.color]'><b><i>\[Blood Bond\]</i> [span_name("[owner.name]")]</b>: [message]</span>"
	for(var/datum/mind/brother as anything in team.members)
		var/mob/living/target = brother.current
		if(QDELETED(target))
			continue
		if(brother != owner)
			target.balloon_alert(target, "you hear a voice")
			target.playsound_local(get_turf(target), 'goon/sounds/radio_ai.ogg', vol = 25, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		to_chat(target, formatted_msg, type = MESSAGE_TYPE_RADIO, avoid_highlighting = (brother == owner))
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, owner.current)
		to_chat(dead_mob, "[link] [formatted_msg]", type = MESSAGE_TYPE_RADIO)

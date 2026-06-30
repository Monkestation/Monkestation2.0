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
	stinger_sound = 'sound/ambience/antag/tatoralert.ogg'
	antag_count_points = 5 //duo antag
	var/datum/action/bb/comms/comms_action
	var/datum/action/bb/gear/gear_action
	VAR_PRIVATE/datum/team/brother_team/team
	///This is used to say who is the big and little brothers. 0 = big, 1 is the middle brother, 2 is little, 3 is little little
	var/brotherRank = 0
	///Whether the confirmation UI popup is active or not
	var/popup = FALSE

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

	team.brothers_left -= 1

	if (prob(team.brother_chance))
		team.brothers_left += 1

	if (team.brothers_left > 0)
		var/mob/living/carbon/carbon_owner = owner.current
		if (istype(carbon_owner))
			carbon_owner.equip_conspicuous_item(new /obj/item/assembly/flash)
			carbon_owner.AddComponentFrom(REF(src), /datum/component/can_flash_from_behind)
			RegisterSignal(carbon_owner, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON, PROC_REF(on_mob_successful_flashed_carbon))

			if (brotherRank > 0)
				to_chat(carbon_owner, span_boldwarning("The Syndicate have higher expectations from you than others. They have granted you an extra flash to convert another person."))
				carbon_owner.balloon_alert(carbon_owner, "extra flash granted!")

	return ..()

/datum/antagonist/brother/on_removal()
	owner.special_role = null
	owner.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)
	UnregisterSignal(owner, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)
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
	play_stinger()
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
	var/name_rank = "Big Brother"
	if(brotherRank > 0)
		name_rank = ""
		for (var/littleness in 2 to brotherRank)
			name_rank += "Little "
		name_rank += "Brother"
	var/formatted_msg = "<span class='[team.color]'><b><i>\[Blood Bond\]</i> [span_name("[name_rank]: [owner.name]")]</b>: [message]</span>"
	for(var/datum/mind/brother as anything in team.members)
		var/mob/living/target = brother.current
		if(QDELETED(target))
			continue
		if(brother != owner)
			target.balloon_alert(target, "you hear a voice")
			target.playsound_local(get_turf(target), 'goon/sounds/misc/talk/radio_ai.ogg', vol = 25, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		to_chat(target, formatted_msg, type = MESSAGE_TYPE_RADIO, avoid_highlighting = (brother == owner))
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, owner.current)
		to_chat(dead_mob, "[link] [formatted_msg]", type = MESSAGE_TYPE_RADIO)

/datum/antagonist/brother/proc/on_mob_successful_flashed_carbon(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash)
	//SIGNAL_HANDLER

	if (flashed.stat == DEAD)
		return

	if (flashed.stat != CONSCIOUS)
		flashed.balloon_alert(source, "unconscious!")
		return

	if (isnull(flashed.mind) || !GET_CLIENT(flashed))
		flashed.balloon_alert(source, "[flashed.p_their()] mind is vacant!")
		return

	// monkestation edit: dont try to convert banned people
	if(is_banned_from(flashed.ckey, list(ROLE_BROTHER, ROLE_SYNDICATE)))
		flashed.balloon_alert(source, "cannot become brother!")
		return
	// monkestation end

	for(var/datum/objective/brother_objective as anything in source.mind.get_all_objectives())
		// If the objective has a target, are we flashing them?
		if(flashed == brother_objective.target?.current)
			flashed.balloon_alert(source, "that's your target!")
			return

	if (flashed.mind.has_antag_datum(/datum/antagonist/brother) || flashed.mind.enslaved_to)
		flashed.balloon_alert(source, "[flashed.p_theyre()] loyal to someone else!")
		return

	if (HAS_TRAIT(flashed, TRAIT_MINDSHIELD) || HAS_MIND_TRAIT(flashed, TRAIT_UNCONVERTABLE)) // monkestation edit: TRAIT_UNCONVERTABLE and remove hardcoded security check
		flashed.balloon_alert(source, "[flashed.p_they()] resist!")
		return

	if (flashed in team.rejected_brothers)
		flashed.balloon_alert(source, "[flashed.p_they()] have rejected you before")
		return

	//The first BB flash against someone should sleep them. They get a popup if they want to join the BB team or not. If they say no they cant be BB flashed anymore
	flashed.SetSleeping(30 SECONDS)
	flash.burn_out()
	join_brother_flashed_popup(source, flashed, flash)

/datum/antagonist/brother/proc/set_brother_rank(newRank)
	brotherRank = newRank

/datum/antagonist/brother/proc/join_brother_flashed_popup(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash)
	if(popup)
		return
	popup = TRUE
	var/response = tgui_alert(flashed, "Visions of a life with [source] as your brother pass through your mind.", "Become brothers?", list("Become a brother", "Reject Brotherhood"), timeout = 30 SECONDS)
	popup = FALSE

	if(response == "Become a brother")
		if (!team.add_brother(flashed, key_name(source))) // Shouldn't happen given the former, more specific checks but just in case
			flashed.balloon_alert(source, "failed!")
			return
		source.log_message("converted [key_name(flashed)] to blood brother", LOG_ATTACK)
		flashed.log_message("was converted by [key_name(source)] to blood brother", LOG_ATTACK)
		log_game("[key_name(flashed)] was made into a blood brother by [key_name(source)]", list(
			"converted" = flashed,
			"converted by" = source,
		))
		flashed.mind.add_memory( \
			/datum/memory/recruited_by_blood_brother, \
			protagonist = flashed, \
			antagonist = owner.current, \
		)
		flashed.balloon_alert(source, "converted")

		UnregisterSignal(source, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)
		source.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)
	else
		team.rejected_brothers.Add(flashed)
		source.balloon_alert(source, "[flashed.name] has rejected you")
		to_chat(flashed, span_big(span_hypnophrase("You wake up forgetting why exactly you fell asleep, and the brotherly visions you had during your sleep")))

	flashed.SetSleeping(0 SECONDS)

/// Global assoc list. [ckey] = [spellbook entry type]
GLOBAL_LIST_EMPTY(wizard_spellbook_purchases_by_key)

/datum/antagonist/wizard
	name = "\improper Space Wizard"
	roundend_category = "wizards/witches"
	antagpanel_category = ANTAG_GROUP_WIZARDS
	job_rank = ROLE_WIZARD
	antag_hud_name = "wizard"
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	ui_name = "AntagInfoWizard"
	suicide_cry = "FOR THE FEDERATION!!"
	preview_outfit = /datum/outfit/wizard
	can_assign_self_objectives = TRUE
	default_custom_objective = "Demonstrate your incredible and destructive magical powers."
	hardcore_random_bonus = TRUE
	antag_count_points = 25 //might bump this up to 30
	var/give_objectives = TRUE
	var/strip = TRUE //strip before equipping
	var/allow_rename = TRUE
	var/datum/team/wizard/wiz_team //Only created if wizard summons apprentices
	var/move_to_lair = TRUE
	var/outfit_type = /datum/outfit/wizard
	var/wiz_age = WIZARD_AGE_MIN /* Wizards by nature cannot be too young. */
	show_to_ghosts = TRUE
	/// This mob's Grand Ritual ability
	var/datum/action/cooldown/grand_ritual/ritual

/datum/antagonist/wizard/antag_token(datum/mind/hosts_mind, mob/spender)
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human , delete_old_mob = TRUE)
		new_mob.mind.make_wizard()
	else
		hosts_mind.make_wizard()

/datum/antagonist/wizard_minion
	name = "Wizard Minion"
	antagpanel_category = ANTAG_GROUP_WIZARDS
	antag_hud_name = "apprentice"
	show_in_roundend = FALSE
	show_name_in_check_antagonists = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE // monkestation addition
	/// The wizard team this wizard minion is part of.
	var/datum/team/wizard/wiz_team

/datum/antagonist/wizard_minion/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard_minion/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.faction |= ROLE_WIZARD
	add_team_hud(current_mob)

/datum/antagonist/wizard_minion/remove_innate_effects(mob/living/mob_override)
	var/mob/living/last_mob = mob_override || owner.current
	last_mob.faction -= ROLE_WIZARD

/datum/antagonist/wizard_minion/on_gain()
	create_objectives()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/wizard_minion/on_removal()
	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return ..()

/datum/antagonist/wizard_minion/proc/create_objectives()
	if(!wiz_team)
		return
	var/datum/objective/custom/custom_objective = new()
	custom_objective.owner = owner
	custom_objective.name = "Serve [wiz_team.master_wizard?.owner]"
	custom_objective.explanation_text = "Serve [wiz_team.master_wizard?.owner]"
	objectives += custom_objective

/datum/antagonist/wizard_minion/get_team()
	return wiz_team

/datum/antagonist/wizard/on_gain()
	if(!owner)
		CRASH("Wizard datum with no owner.")
	assign_ritual()
	equip_wizard()
	if(give_objectives)
		create_objectives()
	if(move_to_lair)
		send_to_lair()
	. = ..()
	if(allow_rename)
		rename_wizard()
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/wizard/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard/get_team()
	return wiz_team

/datum/team/wizard
	name = "\improper Wizard team"
	var/datum/antagonist/wizard/master_wizard

/datum/antagonist/wizard/proc/create_wiz_team()
	wiz_team = new(owner)
	wiz_team.name = "[owner.current.real_name] team"
	wiz_team.master_wizard = src

/// Initialises the grand ritual action for this mob
/datum/antagonist/wizard/proc/assign_ritual()
	ritual = new(owner) //monkestation edit: adds directly to owner instead of owner.current
	RegisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE, PROC_REF(on_ritual_complete))

/datum/antagonist/wizard/proc/send_to_lair()
	if(!owner.current)
		return
	if(!GLOB.wizardstart.len)
		SSjob.SendToLateJoin(owner.current)
		to_chat(owner, "HOT INSERTION, GO GO GO")
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/proc/create_objectives()
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/survive) in objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = owner
				objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				objectives += hijack_objective

/datum/antagonist/wizard/on_removal()
	// Currently removes all spells regardless of innate or not. Could be improved.
	for(var/datum/action/cooldown/spell/spell in owner.current.actions)
		if(spell.target == owner)
			qdel(spell)
			owner.current.actions -= spell

	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return ..()

/datum/antagonist/wizard/proc/equip_wizard()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(strip)
		H.delete_equipment()
	//Wizards are human by default. Use the mirror if you want something else.
	H.set_species(/datum/species/human)
	if(H.age < wiz_age)
		H.age = wiz_age
	H.equipOutfit(outfit_type)

/datum/antagonist/wizard/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["can_change_objective"] = can_assign_self_objectives
	return data

/datum/antagonist/wizard/ui_data(mob/user)
	var/list/data = list()
	var/completed = ritual ? ritual.times_completed : 0
	data["ritual"] = list(\
		"remaining" = GRAND_RITUAL_FINALE_COUNT - completed,
		"next_area" = ritual ? initial(ritual.target_area.name) : "",
	)
	return data

/datum/antagonist/wizard/proc/rename_wizard()
	set waitfor = FALSE

	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/mob/living/wiz_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(tgui_input_text(wiz_mob, "You are the [name]. Would you like to change your name to something else?", "Name change", randomname, MAX_NAME_LEN)), user = wiz_mob)

	if (!newname)
		newname = randomname

	wiz_mob.fully_replace_character_name(wiz_mob.real_name, newname)

/datum/antagonist/wizard/apply_innate_effects(mob/living/mob_override)
	var/mob/living/wizard_mob = mob_override || owner.current
	wizard_mob.faction |= ROLE_WIZARD
	add_team_hud(wizard_mob)
	ritual?.Grant(owner.current)

/datum/antagonist/wizard/remove_innate_effects(mob/living/mob_override)
	var/mob/living/wizard_mob = mob_override || owner.current
	wizard_mob.faction -= ROLE_WIZARD
	if (ritual)
		ritual.Remove(wizard_mob)
		UnregisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE)

/// If we receive this signal, you're done with objectives
/datum/antagonist/wizard/proc/on_ritual_complete()
	SIGNAL_HANDLER
	var/datum/objective/custom/successful_ritual = new()
	successful_ritual.owner = owner
	successful_ritual.explanation_text = "Complete the Grand Ritual at least seven times."
	successful_ritual.completed = TRUE
	objectives = list(successful_ritual)
	UnregisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE)

/datum/antagonist/wizard/get_admin_commands()
	. = ..()
	.["Send to Lair"] = CALLBACK(src, PROC_REF(admin_send_to_lair))

/datum/antagonist/wizard/proc/admin_send_to_lair(mob/admin)
	owner.current.forceMove(pick(GLOB.wizardstart))

//Solo wizard report
/datum/antagonist/wizard/roundend_report()
	var/list/parts = list()

	parts += printplayer(owner)
	if (ritual)
		parts += "<br><B>Grand Rituals completed:</B> [ritual.times_completed]<br>"

	var/count = 1
	var/wizardwin = TRUE
	for(var/datum/objective/objective in objectives)
		if(!objective.check_completion())
			wizardwin = FALSE
		parts += "<B>Objective #[count]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
		count++

	if(wizardwin)
		parts += span_greentext("The wizard was successful!")
	else
		parts += span_redtext("The wizard has failed!")

	var/list/purchases = list()
	for(var/list/log as anything in GLOB.wizard_spellbook_purchases_by_key[owner.key])
		var/datum/spellbook_entry/bought = log[LOG_SPELL_TYPE]
		var/amount = log[LOG_SPELL_AMOUNT]

		purchases += "[amount > 1 ? "[amount]x ":""][initial(bought.name)]"

	if(length(purchases))
		parts += span_bold("[owner.name] used the following spells:")
		parts += purchases.Join(", ")
	else
		parts += span_bold("[owner.name] didn't buy any spells!")

	return parts.Join("<br>")

//Wizard with apprentices report
/datum/team/wizard/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Wizards/witches of [master_wizard.owner.name] team were:</span>"
	parts += master_wizard.roundend_report()
	parts += " "
	parts += "<span class='header'>[master_wizard.owner.name] apprentices and minions were:</span>"
	parts += printplayerlist(members - master_wizard.owner)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

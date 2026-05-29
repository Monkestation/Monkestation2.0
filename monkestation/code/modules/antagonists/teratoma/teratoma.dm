/datum/team/teratoma
	name = "Teratomas"
	member_name = "teratoma"

/datum/antagonist/teratoma
	name = "\improper Teratoma"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_to_ghosts = TRUE
	suicide_cry = "FOR CHAOS!!"
	preview_outfit = /datum/outfit/teratoma
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_TEAM
	antag_count_points = 2
	/// The teratoma team. Used solely to combine all teratomas on the roundend report.
	var/datum/team/teratoma/team

/datum/antagonist/teratoma/on_gain()
	. = ..()
	owner.special_role = ROLE_TERATOMA
	ADD_TRAIT(owner, TRAIT_UNCONVERTABLE, type)

/datum/antagonist/teratoma/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	REMOVE_TRAIT(owner, TRAIT_UNCONVERTABLE, type)
	owner.special_role = null
	return ..()

/datum/antagonist/teratoma/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	ADD_TRAIT(our_mob, TRAIT_EVIL, type)
	STOP_PROCESSING(SSprocessing, src)
	if(istype(owner.current?.loc, /obj/item/mmi))
		RegisterSignal(our_mob.loc, COMSIG_ATOM_EXAMINE, PROC_REF(on_mmi_examine))

/datum/antagonist/teratoma/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	REMOVE_TRAIT(our_mob, TRAIT_EVIL, type)
	UnregisterSignal(our_mob.loc, COMSIG_ATOM_EXAMINE)

/datum/antagonist/teratoma/proc/on_mmi_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!istype(owner.current?.loc, /obj/item/mmi) || source != owner.current.loc)
		UnregisterSignal(source, COMSIG_ATOM_EXAMINE) // we got moved out of the MMI, just unregister the signal
		return
	. += span_warning("There is a small red warning light blinking on it.")

/datum/antagonist/teratoma/greet()
	var/list/parts = list()
	parts += span_big("You are a living teratoma!")
	parts += span_changeling("By all means, you should not exist. <i>Your very existence is a sin against nature itself.</i>")
	parts += span_changeling("You are loyal to <b>nobody</b>, except the forces of chaos itself.")
	parts += span_info("You are able to easily vault tables and ventcrawl, however you cannot use many things like guns, batons, and you are also illiterate and quite fragile.")
	parts += span_hypnophrase("<span style='font-size: 125%'>Spread misery and chaos upon the station.</span>")
	to_chat(owner.current, boxed_message(jointext(parts, "\n")), type = MESSAGE_TYPE_INFO)

/datum/antagonist/teratoma/can_be_owned(datum/mind/new_owner)
	if(!isteratoma(new_owner.current))
		return FALSE
	return ..()

/datum/antagonist/teratoma/create_team(datum/team/teratoma/new_team)
	var/static/datum/team/teratoma/main_teratoma_team
	if(!new_team)
		if(!main_teratoma_team)
			main_teratoma_team = new
			main_teratoma_team.add_objective(new /datum/objective/teratoma)
		new_team = main_teratoma_team
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team
	objectives |= team.objectives

/datum/antagonist/teratoma/get_team()
	return team

/datum/objective/teratoma
	name = "Spread misery and chaos"
	explanation_text = "Spread misery and chaos upon the station."
	completed = TRUE

/datum/outfit/teratoma
	name = "Teratoma (Preview only)"

/datum/outfit/teratoma/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/teratoma)



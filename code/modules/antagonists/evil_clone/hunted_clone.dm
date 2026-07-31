/datum/antagonist/hunted_clone
	name = "\improper Hunted Clone"
	show_in_antagpanel = TRUE
	antagpanel_category = "Hunted Clones"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_count_points = 0

/datum/antagonist/hunted_clone/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/hunted_clone/greet()
	. = ..()
	to_chat(owner, "<B>You feel as though you will be hunted down for sport.</B>")
	to_chat(owner, "<span class='warningplain'><font color=red size='7'><B>You are not an antagonist, you should only be fighting to defend yourself and fellow clones.</B></font></span>")
	owner.announce_objectives()

/datum/antagonist/hunted_clone/forge_objectives()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/antagonist/hunted_clone/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = owner.current
	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/antagonist/hunted_clone/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = owner.current
	UnregisterSignal(current_mob, COMSIG_ATOM_EXAMINE)

/datum/antagonist/hunted_clone/proc/on_examine(mob/living/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/clone = owner.current

	var/obscured = clone.check_obscured_slots()
	if(!(obscured & ITEM_SLOT_EYES))
		examine_text += span_yellow("[clone.p_Their()] eyes are that of prey.")

/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 15 chemicals."
	helptext = "We become much smaller, allowing us to slip out of cuffs and climb through vents. Right-click to drop items."
	button_icon_state = "lesser_form"
	chemical_cost = 15
	dna_cost = 1
	/// Whether to allow the transformation animation to play
	var/transform_instantly = FALSE
	/// Whether to drop our stuff when we finish turning into a monkey.
	var/drop_stuff = FALSE

/datum/action/changeling/lesserform/Grant(mob/granted_to)
	. = ..()
	if (!owner)
		return
	RegisterSignal(granted_to, COMSIG_MONKEY_HUMANIZE, PROC_REF(changed_form))
	RegisterSignal(granted_to, COMSIG_HUMAN_MONKEYIZE, PROC_REF(on_monkeyize))

/datum/action/changeling/lesserform/Remove(mob/remove_from)
	UnregisterSignal(remove_from, list(COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	return ..()

/datum/action/changeling/lesserform/Trigger(trigger_flags)
	drop_stuff = (trigger_flags & TRIGGER_SECONDARY_ACTION)
	return ..()

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || HAS_TRAIT(user, TRAIT_NO_TRANSFORM))
		return FALSE
	..()
	return ismonkeybasic(user) ? unmonkey(user) : become_monkey(user)


/// Stop being a monkey
/datum/action/changeling/lesserform/proc/unmonkey(mob/living/carbon/human/user)
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "can't transform in pipes!")
		return FALSE
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/chosen_form = select_form(changeling, user)
	if(!chosen_form)
		return FALSE
	to_chat(user, span_notice("We transform our appearance."))
	var/datum/dna/chosen_dna = chosen_form.dna
	var/datum/species/chosen_species = chosen_dna.species
	user.humanize(species = chosen_species, instant = transform_instantly)

	changeling.transform(user, chosen_form)
	user.regenerate_icons()
	return TRUE

/// Returns the form to transform back into, automatically selects your only profile if you only have one
/datum/action/changeling/lesserform/proc/select_form(datum/antagonist/changeling/changeling, mob/living/carbon/human/user)
	if (!changeling)
		return
	if (length(changeling.stored_profiles) == 1)
		return changeling.first_profile
	return changeling?.select_dna()

/// Become a monkey
/datum/action/changeling/lesserform/proc/become_monkey(mob/living/carbon/human/user)
	to_chat(user, span_warning("Our genes cry out!"))
	user.monkeyize(instant = transform_instantly)
	return TRUE

/// Called when you become a human or monkey, whether or not it was voluntary
/datum/action/changeling/lesserform/proc/changed_form()
	SIGNAL_HANDLER
	build_all_button_icons(update_flags = UPDATE_BUTTON_NAME | UPDATE_BUTTON_ICON)

/datum/action/changeling/lesserform/proc/on_monkeyize(mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(drop_stuff)
		user.unequip_everything()
		drop_stuff = FALSE
	changed_form()

/datum/action/changeling/lesserform/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if (ismonkeybasic(owner))
		name = "Human Form"
		desc = "We change back into a human. Costs 5 chemicals."
	else
		name = initial(name)
		desc = initial(desc)
	return ..()

/datum/action/changeling/lesserform/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = ismonkeybasic(owner) ? "human_form" : initial(button_icon_state)
	return ..()

// Parent of all borer actions
/datum/action/cooldown/borer
	button_icon = 'icons/mob/actions/actions_borer.dmi'
	cooldown_time = 0

	check_flags = AB_CHECK_INCAPACITATED

	/// Text used to explain the ability more closelly in the antagonist TGUI panel
	var/ability_explanation = ""

	/// How many chemicals this costs
	var/chemical_cost = 0
	/// How many stat evo points are needed to use this ability
	var/stat_evo_points = 0

	/// Does this ability need a human host to be triggered?
	var/requires_host = FALSE
	/// Does this ability stop working when the host has sugar?
	var/sugar_restricted = FALSE

/datum/action/cooldown/borer/New(Target, original)
	. = ..()
	var/compiled_string = ""
	if(chemical_cost)
		compiled_string += "([chemical_cost] chemical[chemical_cost == 1 ? "" : "s"])"
	if(stat_evo_points)
		compiled_string += " ([stat_evo_points] stat point[stat_evo_points == 1 ? "" : "s"])"
	name += compiled_string
	RegisterSignal(src, COMSIG_ACTION_TRIGGER, PROC_REF(check_conditions))

/datum/action/cooldown/borer/Destroy(force)
	UnregisterSignal(src, COMSIG_ACTION_TRIGGER)
	if(owner)
		if(requires_host)
			UnregisterSignal(owner, COMSIG_HOST_CHANGED)
		if(sugar_restricted)
			UnregisterSignal(owner, COMSIG_SUGAR_CHANGED)
	return ..()

/datum/action/cooldown/borer/Grant(mob/grant_to)
	if(owner)
		if(requires_host)
			UnregisterSignal(owner, COMSIG_HOST_CHANGED)
		if(sugar_restricted)
			UnregisterSignal(owner, COMSIG_SUGAR_CHANGED)
	. = ..()
	if(grant_to)
		if(requires_host)
			RegisterSignal(grant_to, COMSIG_HOST_CHANGED, PROC_REF(update_status_on_signal))
		if(sugar_restricted)
			RegisterSignal(grant_to, COMSIG_SUGAR_CHANGED, PROC_REF(update_status_on_signal))

/// Use for conditions that can be properly expected and you can update with a signal/by directly calling build_all_button_icons(UPDATE_BUTTON_STATUS)
/datum/action/cooldown/borer/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	if(!iscorticalborer(owner)) // Our abilities very much need borers, for now
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return FALSE

	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(requires_host == TRUE && isnull(cortical_owner.human_host))
		if(feedback)
			owner.balloon_alert(owner, "host required")
		return FALSE
	if(sugar_restricted == TRUE && cortical_owner.host_sugar())
		if(feedback)
			owner.balloon_alert(owner, "cannot function with sugar in host")
		return FALSE

/// Used for conditions that can change at any time
/datum/action/cooldown/borer/proc/check_conditions()
	SIGNAL_HANDLER
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(cortical_owner.stat_evolution < stat_evo_points)
		cortical_owner.balloon_alert(cortical_owner, "need [stat_evo_points] evolution points")
		return COMPONENT_ACTION_BLOCK_TRIGGER

	if(cortical_owner.chemical_storage < chemical_cost)
		cortical_owner.balloon_alert(cortical_owner, "need [chemical_cost] chemicals")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/asset/simple/borer_icons

/datum/asset/simple/borer_icons/register()
	for(var/datum/action/cooldown/borer/ability as anything in subtypesof(/datum/action/cooldown/borer))
		add_borer_icon(initial(ability.button_icon), initial(ability.button_icon_state))
	return ..()

/datum/asset/simple/borer_icons/proc/add_borer_icon(borer_icon, borer_icon_state)
	assets[SANITIZE_FILENAME("borer.[borer_icon_state].png")] = icon(borer_icon, borer_icon_state)

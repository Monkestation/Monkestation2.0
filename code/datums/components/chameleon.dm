/**
 * Chameleon component
 * Gives the item chameleon action
 * As well as it's properties
 */
/datum/component/chameleon

	/// List of types blacklisted from selection
	var/list/chameleon_blacklist
	/// Name
	var/chameleon_name = ""
	/// What types of items will it be able to disguise into
	var/chameleon_type
	/// Our chameleon action
	var/datum/action/item_action/chameleon/change/chameleon_action
	/// Item parent
	var/obj/item/item_parent

/datum/component/chameleon/Initialize(/datum/action/item_action/chameleon/change/chameleon_action, chameleon_type, chameleon_name, chameleon_blacklist)
	. = ..()
	item_parent = parent
	chameleon_action = new chameleon_action
	chameleon_action.chameleon_type = chameleon_type
	chameleon_action.chameleon_name = chameleon_name
	chameleon_action.chameleon_blacklist = chameleon_blacklist
	chameleon_action.initialize_disguises()
	item_parent.add_item_action(chameleon_action)

/datum/component/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/datum/component/chameleon/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/// Signal handler for attackby()
/datum/component/chameleon/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	attempt_action_hide(attacking_item, user, modifiers, attack_modifiers)

/// Hide our action on multitool
/datum/component/chameleon/proc/attempt_action_hide(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour != TOOL_MULTITOOL)
		return

	if(chameleon_action.hidden)
		chameleon_action.hidden = FALSE
		item_parent.actions += chameleon_action
		chameleon_action.Grant(user)
		log_game("[key_name(user)] has removed the disguise lock on the chameleon ([item_parent.name]) with [attacking_item]")
		return ITEM_INTERACT_SUCCESS
	else
		chameleon_action.hidden = TRUE
		item_parent.actions -= chameleon_action
		chameleon_action.Remove(user)
		log_game("[key_name(user)] has locked the disguise of the chameleon ([item_parent.name]) with [attacking_item]")
		return ITEM_INTERACT_SUCCESS

/// Emp act
/datum/component/chameleon/proc/on_emp_act(datum/source, severity)
	SIGNAL_HANDLER

	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

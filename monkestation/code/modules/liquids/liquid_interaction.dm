///This element allows for items to interact with liquids on turfs.
/datum/component/liquids_interaction
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/interaction_callback

/datum/component/liquids_interaction/Initialize(on_interaction_callback)
	. = ..()

	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	interaction_callback = CALLBACK(parent, on_interaction_callback)

/datum/component/liquids_interaction/Destroy(force)
	interaction_callback = null
	return ..()

/datum/component/liquids_interaction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interacting))

/datum/component/liquids_interaction/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM)

/datum/component/liquids_interaction/proc/on_interacting(datum/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER
	var/turf/turf_target = interacting_with
	if(!isturf(interacting_with) || !turf_target.liquids)
		return NONE
	if(interaction_callback.Invoke(parent, turf_target, user, turf_target.liquids))
		return ITEM_INTERACT_SUCCESS

/// A simple component that grants full pressure and temperature immunity while ventcrawling.
/datum/component/vent_safety
	dupe_mode = COMPONENT_DUPE_SOURCES
	/// A list of traits to grant while inside of a vent.
	var/static/list/traits_to_give = list(
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
	)

/datum/component/vent_safety/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/vent_safety/RegisterWithParent()
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), PROC_REF(give_pipe_resistance))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING), PROC_REF(take_pipe_resistance))

/datum/component/vent_safety/UnregisterFromParent()
	UnregisterSignal(parent, list(SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING)))
	take_pipe_resistance()

/datum/component/vent_safety/proc/give_pipe_resistance(mob/living/source)
	SIGNAL_HANDLER
	parent.add_traits(traits_to_give, REF(src))

/datum/component/vent_safety/proc/take_pipe_resistance(mob/living/source)
	SIGNAL_HANDLER
	parent.remove_traits(traits_to_give, REF(src))

/datum/quirk/intrusivethoughts
	name = "Intrusive Thoughts"
	desc = "You suffer from impulsive and intrusive thoughts."
	icon = FA_ICON_USER_FRIENDS
	value = 0
	/// Weakref to the trauma we give out
	var/datum/weakref/added_trama_ref
	species_blacklist = list(SPECIES_IPC)

/datum/quirk/intrusivethoughts/add(client/client_source)
	if(!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	// Setup our brain trauma.
	// also as we inherit the names and values from our quirk.
	var/datum/brain_trauma/special/intrusive_thoughts/added_trauma = new()

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)


/datum/quirk/intrusivethoughts/remove()
	QDEL_NULL(added_trama_ref)

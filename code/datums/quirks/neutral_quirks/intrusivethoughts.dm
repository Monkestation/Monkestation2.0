/datum/quirk/intrusivethoughts
	name = "Intrusive Thoughts"
	desc = "You suffer from impulsive and intrusive thoughts."
	icon = FA_ICON_PERSON_CIRCLE_PLUS
	value = 0
	species_blacklist = list(SPECIES_IPC)
	/// Weakref to the trauma we give out
	var/datum/weakref/added_trama_ref

/datum/quirk/intrusivethoughts/add(client/client_source)
	if(!iscarbon(quirk_holder))
		return
	/// Character with the quirk
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	/// The Brain Trauma this quirk creates
	var/datum/brain_trauma/special/intrusive_thoughts/added_trauma = new()

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)


/datum/quirk/intrusivethoughts/remove()
	QDEL_NULL(added_trama_ref)

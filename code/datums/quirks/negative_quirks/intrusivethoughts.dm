/datum/quirk/intrusivethoughts
	name = "Intrusive Thoughts"
	desc = "You suffer from impulsive and intrusive thoughts."
	icon = FA_ICON_USER_FRIENDS
	value = -6
	medical_record_text = "Patient displays sudden impulsive behaviors and thoughts."
	hardcore_value = 6
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
	added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	added_trauma.name = name
	added_trauma.desc = medical_record_text
	added_trauma.scan_desc = LOWER_TEXT(name)
	added_trauma.gain_text = null
	added_trauma.lose_text = null

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)


/datum/quirk/intrusivethoughts/remove()
	QDEL_NULL(added_trama_ref)

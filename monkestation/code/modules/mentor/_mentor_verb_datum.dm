GENERAL_PROTECT_DATUM(/datum/mentor_verb)

/**
 * This is the mentor verb datum. It is used to store the verb's information and handle the verb's functionality.
 * All of this is setup for you, and you should not be defining this manually.
 * That means you reader.
 */
/datum/mentor_verb
	var/name //! The name of the verb.
	var/description //! The description of the verb.
	var/category //! The category of the verb.
	var/permissions //! The permissions required to use the verb.
	var/match_exact_permissions //! Check if all permissions required or at least one is required for the verb.
	var/visibility_flag //! The flag that determines if the verb is visible.
	VAR_PROTECTED/verb_path //! The path to the verb proc.

/datum/mentor_verb/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/// Assigns the verb to the admin.
/datum/mentor_verb/proc/assign_to_client(client/mentor)
	add_verb(mentor, verb_path)

/// Unassigns the verb from the admin.
/datum/mentor_verb/proc/unassign_from_client(client/mentor)
	remove_verb(mentor, verb_path)

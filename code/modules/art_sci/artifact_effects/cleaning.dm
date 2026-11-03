/datum/artifact_effect/soap
	examine_hint = "Smells nice."
	examine_discovered = "Seems to clean things."
	discovered_credits = CARGO_CRATE_VALUE
	artifact_size = ARTIFACT_SIZE_TINY
	type_name = "Cleaning Effect"

/datum/artifact_effect/soap/setup()
	our_artifact.holder.AddComponent(/datum/component/slippery, 80)
	our_artifact.holder.AddComponent(/datum/component/cleaner, 2 SECONDS, 0.1, CLEAN_ALL ,CALLBACK(src, TYPE_PROC_REF(/datum/artifact_effect/soap,should_clean)), CALLBACK(src, TYPE_PROC_REF(/datum/artifact_effect/soap,sorry_nothing)))

/datum/artifact_effect/soap/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(isitem(our_artifact.holder))
		var/obj/item/yep_its_an_item = our_artifact.holder
		if(yep_its_an_item.check_allowed_items(atom_to_clean))
			return CLEAN_ALLOWED
		return CLEAN_BLOCKED
	return FALSE
/datum/artifact_effect/soap/proc/sorry_nothing(datum/source, atom/target, mob/living/user, clean_succeeded)
	return

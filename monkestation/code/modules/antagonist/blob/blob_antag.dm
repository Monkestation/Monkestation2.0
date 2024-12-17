/datum/antagonist/blob/infection/on_gain()
	ADD_TRAIT(owner.current, TRAIT_BLOB_ALLY, DISEASE_TRAIT)
	return ..()

/datum/antagonist/blob/infection/on_removal()
	REMOVE_TRAIT(owner.current, TRAIT_BLOB_ALLY, DISEASE_TRAIT)
	return ..()

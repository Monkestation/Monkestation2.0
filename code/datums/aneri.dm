/// Base type for datums whose data lives on the Rust side.
/// It holds the key that Rust uses to find that data.
/datum/aneri
	VAR_FINAL/__aneri_key_low
	VAR_FINAL/__aneri_key_high

/datum/aneri/Del()
	if(!gc_destroyed)
		gc_destroyed = world.time

		// Yes this is the same as what's found in qdel(). Yes it does need to be here
		// Get off my back
		SEND_SIGNAL(src, COMSIG_QDELETING, TRUE)
		UNLINT(Destroy())
	return ..()

/datum/aneri/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, __aneri_key_low) || var_name == NAMEOF(src, __aneri_key_high)) // no. bad.
		return FALSE
	return ..()

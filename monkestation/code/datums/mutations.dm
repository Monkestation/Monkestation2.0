/datum/mutation
	/// This mutation cannot appear in random DNA disks.
	/// This is separate from the `locked` var so that otherwise locked mutations can appear in them.
	var/random_locked = FALSE

/datum/mutation/proc/valid_chromosome_types()
	. = list()
	if(can_chromosome == CHROMOSOME_NEVER)
		return

	if(stabilizer_coeff != -1)
		. += /obj/item/chromosome/stabilizer
	if(synchronizer_coeff != -1)
		. += /obj/item/chromosome/synchronizer
	if(power_coeff != -1)
		. += /obj/item/chromosome/power
	if(energy_coeff != -1)
		. += /obj/item/chromosome/energy

/datum/mutation/bad_dna
	random_locked = TRUE

/datum/mutation/race
	random_locked = TRUE

/datum/mutation/chameleon/changeling
	random_locked = TRUE

/datum/mutation/xray
	random_locked = TRUE

/datum/mutation/laser_eyes
	random_locked = TRUE

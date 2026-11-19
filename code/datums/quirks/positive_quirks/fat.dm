/datum/quirk/fat
	name = "Chronically Overweight"
	desc = "It's just water weight, you're big-boned, at least that's what you tell yourself. Your body seems to make calories out of thin air, you'll end up overweight no matter what you do."
	icon = FA_ICON_BURGER
	value = 4
	gain_text = span_notice("You feel heavy and overfull.")
	lose_text = span_danger("You no longer feel so full.")
	medical_record_text = "Patient has a metabolism that captures calories from unknown sources."
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_PROCESSES
	no_process_traits = list(TRAIT_STASIS, TRAIT_NOHUNGER, TRAIT_GENELESS)
	species_blacklist = list(SPECIES_IPC, SPECIES_ETHEREAL, SPECIES_OOZELING)

/datum/quirk/fat/process(seconds_per_tick, times_fired)
	if(quirk_holder.nutrition <= NUTRITION_LEVEL_FAT)
		quirk_holder.nutrition += 10 * seconds_per_tick

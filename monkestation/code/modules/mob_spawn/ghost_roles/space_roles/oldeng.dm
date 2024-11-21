/datum/outfit/oldeng
	ears = /obj/item/radio/headset/headset_old
	skillchips = /obj/item/skillchip/job/engineer
	id = /obj/item/card/id/advanced/old
	id_trim = /datum/id_trim/away/old/eng

/datum/outfit/oldeng/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_UNCOMMON)
	R.freqlock = RADIO_FREQENCY_LOCKED
	R.independent = TRUE
	..()

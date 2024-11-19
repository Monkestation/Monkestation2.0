/datum/outfit/oldsec
	ears = /obj/item/radio/headset/headset_old/alt
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/oldsec/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_UNCOMMON)
	R.freqlock = RADIO_FREQENCY_LOCKED
	R.independent = TRUE
	..()

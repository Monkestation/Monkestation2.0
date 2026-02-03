/obj/effect/anomaly/monkey //Monkey Anomaly (Random Chimp Event)
	name = "Screeching Anomaly"
	desc = "An anomalous one-way gateway that leads straight to some sort of a ape dimension."
	icon_state = "dimensional_overlay"
	color = "#a76d17"
	lifespan = 35 SECONDS
	var/active = TRUE

/obj/effect/anomaly/monkey/anomalyEffect(seconds_per_tick)
	..()

	playsound(src, SFX_SCREECH, vol = 33, vary = 1, mixer_channel = CHANNEL_MOB_SOUNDS)

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	if(!active)
		active = TRUE
		return

	if(prob(15))
		new /mob/living/carbon/human/species/monkey/angry(src.loc)
	else
		new /mob/living/carbon/human/species/monkey(src.loc)
	active = FALSE

/obj/effect/anomaly/monkey/detonate()
	if(prob(25))
		new /mob/living/basic/gorilla(src.loc)

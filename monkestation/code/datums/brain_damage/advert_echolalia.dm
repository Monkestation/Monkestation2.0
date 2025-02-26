/datum/brain_trauma/mild/advert_force_speak
	name = "Advertisement Echolalia"
	desc = "Patient has an unsuppressible impulse to repeat consumerist slogans."
	scan_desc = "advertisement echolalia"
	gain_text = span_notice("You feel the need to mimic advertisements.")
	lose_text = span_notice("You no longer feel the need to mimic advertisements.")

/datum/brain_trauma/mild/advert_force_speak/on_gain()
	src.owner.AddComponentFrom(REF(src), /datum/component/advert_force_speak, rand(2 MINUTES))
	return ..()

/datum/brain_trauma/mild/advert_force_speak/on_lose(silent)
	src.owner.RemoveComponentSource(REF(src), /datum/component/advert_force_speak)
	return ..()

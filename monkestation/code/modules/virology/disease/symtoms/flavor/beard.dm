/datum/symptom/beard
	name = "Facial Hypertrichosis"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	max_multiplier = 5
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/beard/activate(mob/living/mob)
	if(ishuman(mob))
		addtimer(CALLBACK(src, PROC_REF(give_beard), mob), 5 SECONDS, TIMER_UNIQUE)

/datum/symptom/beard/proc/give_beard(mob/living/carbon/human/victim)
	if(QDELETED(src) || QDELETED(victim))
		return
	var/beard_name = ""
	if(multiplier >= 1 && multiplier < 2)
		beard_name = "Beard (Jensen)"
	if(multiplier >= 2 && multiplier < 3)
		beard_name = "Beard (Full)"
	if(multiplier >= 3 && multiplier < 4)
		beard_name = "Beard (Very Long)"
	if(multiplier >= 4)
		beard_name = "Beard (Dwarf)"
	if(beard_name != "" && victim.facial_hairstyle != beard_name)
		victim.set_facial_hairstyle(beard_name, update = TRUE)
		to_chat(victim, span_warning("Your chin itches."))

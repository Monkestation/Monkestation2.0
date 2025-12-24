/datum/symptom/mommi_shrink
	name = "Dysplasia Syndrome"
	desc = "Rapidly restructures the body of the infected, causing them to shrink in size."
	badness = EFFECT_DANGER_FLAVOR
	severity = 1
	stage = 2
	var/activated = FALSE

/datum/symptom/mommi_shrink/activate(mob/living/mob)
	if(mob.current_size <= 0.25)
		return
	if(activated)
		return
	to_chat(mob, "<span class = 'warning'>You feel small...</span>")
	mob.update_transform(0.5/RESIZE_DEFAULT_SIZE)
	mob.pass_flags |= PASSTABLE
	activated = TRUE

/datum/symptom/mommi_shrink/deactivate(mob/living/mob, datum/disease/acute/disease, safe = FALSE)
	if(!activated)
		return
	to_chat(mob, "<span class = 'warning'>You feel like an adult again.</span>")
	mob.update_transform(2/RESIZE_DEFAULT_SIZE)
	mob.pass_flags &= ~PASSTABLE
	activated = FALSE

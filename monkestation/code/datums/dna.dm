/datum/dna
	var/body_height = "Normal"

/datum/dna/proc/update_body_height()
	var/mob/living/carbon/human/human_holder = holder
	if(!istype(human_holder))
		return
	var/height = GLOB.body_heights[body_height]
	if(isnull(height))
		return
	human_holder.set_mob_height(height)

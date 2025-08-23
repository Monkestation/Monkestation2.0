/datum/dna
	var/body_height = "Normal"

/datum/dna/proc/update_body_height()
	if(!ishuman(holder) || isdummy(holder))
		return
	var/mob/living/carbon/human/human_holder = holder
	var/height = GLOB.body_heights[body_height]
	if(height)
		human_holder.set_mob_height(height)

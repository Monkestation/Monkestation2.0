//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = SPECIES_GOLEM_ALIEN
	fixed_mut_color = "#333333"
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/internal/tongue/abductor
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown
	examine_limb_id = SPECIES_GOLEM

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(FALSE)
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(brute = 1 * seconds_per_tick, burn = 1 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
	H.adjustToxLoss(-1 * seconds_per_tick)
	H.adjustOxyLoss(-1 * seconds_per_tick)

/datum/experiment/scanning/random/serverlink
	name = "Serverlink Salvage Experiment"
	description = "The analysis methods of advanced serverlinks have caught our researchers eyes. Provide any serverlink better than the standard model for reverse engineering in the experimental destructive analyzer."
	exp_tag = "Salvage Scan"
	total_requirement = 1
	possible_types = list(/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect)
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

/datum/experiment/scanning/random/casing
	name = "Grenade Casing Salavage Experiment"
	description = "We belive we can learn from applied use of chemical grenades. Deconstruct any large grenade casings from external parties in the experimental destructive analyzer."
	exp_tag = "Salvage Scan"
	total_requirement = 1
	possible_types = list(/obj/item/grenade/chem_grenade/large/bioterrorfoam, /obj/item/grenade/chem_grenade/large/tuberculosis,) //Any special grenade casings.
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

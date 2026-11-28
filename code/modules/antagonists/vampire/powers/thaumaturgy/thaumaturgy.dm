/datum/discipline/thaumaturgy
	name = "Thaumaturgy"
	discipline_explanation = "Thaumaturgy is the closely guarded form of blood magic practiced by the vampiric clan Tremere."
	icon_state = "thaumaturgy"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/cooldown/vampire/targeted/bloodbolt)
	level_2 = list(/datum/action/cooldown/vampire/targeted/bloodbolt, /datum/action/cooldown/vampire/bloodshield)
	level_3 = list(/datum/action/cooldown/vampire/targeted/bloodbolt, /datum/action/cooldown/vampire/bloodshield, /datum/action/cooldown/vampire/targeted/theft_of_vitae)
	level_4 = list(/datum/action/cooldown/vampire/targeted/bloodbolt, /datum/action/cooldown/vampire/bloodshield, /datum/action/cooldown/vampire/targeted/theft_of_vitae, /datum/action/cooldown/vampire/targeted/cauldron_of_blood)
	level_5 = list(/datum/action/cooldown/vampire/targeted/bloodbolt, /datum/action/cooldown/vampire/bloodshield, /datum/action/cooldown/vampire/targeted/theft_of_vitae, /datum/action/cooldown/vampire/targeted/cauldron_of_blood/two)

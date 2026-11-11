/datum/discipline/obfuscate
	name = "Obfuscate"
	discipline_explanation = "Obfuscate is a Discipline that allows vampires to conceal themselves, deceive the mind of others, or make them ignore what the user does not want to be seen."
	icon_state = "obfuscate"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/cooldown/vampire/unseen_presence)
	level_2 = list(/datum/action/cooldown/vampire/unseen_presence/two, /datum/action/cooldown/vampire/targeted/trespass)
	level_3 = list(/datum/action/cooldown/vampire/unseen_presence/three, /datum/action/cooldown/vampire/targeted/trespass/two)
	level_4 = list(/datum/action/cooldown/vampire/unseen_presence/four, /datum/action/cooldown/vampire/targeted/trespass/three, /datum/action/cooldown/vampire/mask_of_a_thousand_faces)
	level_5 = null
	vassal_power = /datum/action/cooldown/vampire/unseen_presence

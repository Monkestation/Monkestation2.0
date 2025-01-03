/datum/vampire_ability/masquerade
	name = "Masquerade"
	desc = "Hide your vampiric traits. \
		Can be toggled off while dead. \
		Disables most of your abilities. \
		Regulates your body temperature. \
		Shows your reflection in mirrors. \
		Fakes your blood and genes on analyzers. \
		Hides your pale grey skin and glowing eyes. \
		Cost scales with Discretion."
	granted_action = /datum/action/cooldown/vampire/masquerade
	min_rank = 1 // thralls can't get this

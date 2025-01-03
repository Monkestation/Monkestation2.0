/datum/vampire_ability/frenzy
	name = "Frenzy"
	desc = "Enter a state of total bloodlust for 30 seconds. \
	Increases Brutality and Pursuit scaling by 50%. \
	Makes you immune to critical status and pain. \
	Disables Masquerade until the duration ends. \
	Rapidly drains lifeforce while active. \
	Has a cooldown of 2 minutes. \
	Can't be ended early."
	granted_action = /datum/action/cooldown/vampire/frenzy
	stat_reqs = list(VAMPIRE_STAT_BRUTALITY = 6)

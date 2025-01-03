/datum/vampire_ability/reconstitute
	name = "Reconstitute"
	desc = "Convert your lifeforce into a physical form, then reconstitute it into a new body. \
		Your old body turns to dust and you drop all of your items to the floor. The process takes time. \
		Has a long cooldown, but works even as a brain. Doesn't retain nanites, implants, etc."
	stat_reqs = list(VAMPIRE_STAT_RECOVERY = 12)
	granted_action = /datum/action/cooldown/vampire/reconstitute

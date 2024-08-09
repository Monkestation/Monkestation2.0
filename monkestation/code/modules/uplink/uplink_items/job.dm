/datum/uplink_item/role_restricted/minibible
	name = "Miniature Bible"
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	progression_minimum = 5 MINUTES
	cost = 1
	item = /obj/item/storage/book/bible/mini
	restricted_roles = list(JOB_CHAPLAIN, JOB_CLOWN)

/datum/uplink_item/role_restricted/reverse_bear_trap
	surplus = 60

/datum/uplink_item/role_restricted/modified_syringe_gun
	surplus = 50

/datum/uplink_item/role_restricted/power_gloves
	name = "Power Gloves"
	desc = "Are the Engineers on your station creating too much power? Use this to set them in their place. T-ray scanner not included"
	cost = 8
	item = /obj/item/clothing/gloves/color/yellow/power_gloves
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)

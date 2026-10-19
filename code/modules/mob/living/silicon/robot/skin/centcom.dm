/datum/robot_skin/centcom
	abstract_type = /datum/robot_skin/centcom

/datum/robot_skin/centcom/default
	name = "CentCom"
	icon_state = "centcomborg"
	icon_state_light = "centcomborg"
	hat_offset = list(
		"north" = list(0, 3),
		"east" = list(0, 3),
		"south" = list(0, 3),
		"west" = list(0, 3),
	)
	badge_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)

/datum/robot_skin/centcom/kerfus
	name = "CentCom Kerfus"
	icon_state = "kerfus_centcom"
	icon_state_light = "kerfus_centcom"
	hat_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)
	badge_offset = list(
		"north" = list(0, -6),
		"east" = list(0, -6),
		"south" = list(0, -6),
		"west" = list(0, -6),
	)
	traits = list(TRAIT_CAT)

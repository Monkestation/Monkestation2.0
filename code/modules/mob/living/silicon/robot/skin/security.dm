/datum/robot_skin/security
	abstract_type = /datum/robot_skin/security

/datum/robot_skin/security/default
	name = "Security"
	icon_state = "sec"
	icon_state_light = "sec"
	icon_state_transform = "sec_transform"
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

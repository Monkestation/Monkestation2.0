/datum/robot_skin/janitor
	abstract_type = /datum/robot_skin/janitor

/datum/robot_skin/janitor/default
	name = "Janitor"
	icon_state = "janitor"
	icon_state_light = "janitor"
	icon_state_transform = "janitor_transform"
	transformation_duration = 2.2 SECONDS
	hat_offset = list(
		"north" = list(0, -5),
		"east" = list(0, -5),
		"south" = list(0, -5),
		"west" = list(0, -5),
	)
	badge_offset = list(
		"north" = list(0, -2),
		"east" = list(0, -2),
		"south" = list(0, -2),
		"west" = list(0, -2),
	)

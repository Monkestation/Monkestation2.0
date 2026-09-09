/datum/robot_skin/medical
	abstract_type = /datum/robot_skin/medical

/datum/robot_skin/medical/default
	name = "Machinified Doctor"
	icon_state = "medical"
	icon_state_light = "medical"
	icon_state_transform = "medical_transform"
	transformation_duration = 3.4 SECONDS
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

/datum/robot_skin/medical/qualified
	name = "Qualified Doctor"
	icon_state = "qualified_doctor"
	icon_state_light = "qualified_doctor"
	hat_offset = list(
		"north" = list(0, 3),
		"east" = list(0, 3),
		"south" = list(0, 3),
		"west" = list(0, 3),
	)
	badge_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)

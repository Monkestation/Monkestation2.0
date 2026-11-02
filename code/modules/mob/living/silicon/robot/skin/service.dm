/datum/robot_skin/service
	abstract_type = /datum/robot_skin/service

/datum/robot_skin/service/default
	name = "Butler"
	icon_state = "service_m"
	icon_state_light = "service_m"
	icon_state_transform = "service_m_transform"
	transformation_duration = 4.3 SECONDS
	hat_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)
	badge_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)

/datum/robot_skin/service/waitress
	name = "Waitress"
	icon_state = "service_f"
	icon_state_light = "service_f"
	icon_state_transform = "service_female_transform"
	transformation_duration = 4.5 SECONDS
	hat_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)
	badge_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)

/datum/robot_skin/service/bro
	name = "Bro"
	icon_state = "brobot"
	icon_state_light = "brobot"
	icon_state_transform = "brobot_transform"
	transformation_duration = 5.5 SECONDS
	hat_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)
	badge_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)

/datum/robot_skin/service/kent
	name = "Kent"
	icon_state = "kent"
	icon_state_light = "medical"
	icon_state_transform = "kent_transform"
	transformation_duration = 3.6 SECONDS
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

/datum/robot_skin/service/tophat
	name = "Tophat"
	icon_state = "tophat"
	icon_state_light = "tophat"
	icon_state_transform = "tophat_transform"
	transformation_duration = 5.2 SECONDS
	badge_offset = list(
		"north" = list(0, -3),
		"east" = list(0, -3),
		"south" = list(0, -3),
		"west" = list(0, -3),
	)

/datum/robot_skin/service/kerfus
	name = "Service Kerfus"
	icon = CYBORG_ICON_CARGO
	icon_state = "kerfus_service"
	icon_state_light = "kerfus_service"
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

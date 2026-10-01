/datum/robot_skin/miner
	abstract_type = /datum/robot_skin/miner

/datum/robot_skin/miner/default
	name = "Lavaland Miner"
	icon_state = "miner"
	icon_state_light = "miner"
	icon_state_transform = "miner_transform"
	transformation_duration = 2.9 SECONDS
	hat_offset = list(
		"north" = list(0, -1),
		"east" = list(0, -1),
		"south" = list(0, -1),
		"west" = list(0, -1),
	)
	badge_offset = list(
		"north" = list(0, -2),
		"east" = list(0, -2),
		"south" = list(0, -2),
		"west" = list(0, -2),
	)

/datum/robot_skin/miner/asteroid
	name = "Asteroid Miner"
	icon_state = "minerOLD"
	icon_state_light = "minerOLD"
	icon_state_transform = "minerOLD_transform"
	transformation_duration = 2.9 SECONDS
	hat_offset = list(
		"north" = list(0, -1),
		"east" = list(0, -1),
		"south" = list(0, -1),
		"west" = list(0, -1),
	)
	badge_offset = list(
		"north" = list(0, -2),
		"east" = list(0, -2),
		"south" = list(0, -2),
		"west" = list(0, -2),
	)

/datum/robot_skin/miner/spider
	name = "Spider"
	icon_state = "spidermin"
	icon_state_light = "spidermin"
	hat_offset = list(
		"north" = list(0, -2),
		"east" = list(-2, -2),
		"south" = list(0, -2),
		"west" = list(2, -2),
	)
	badge_offset = list(
		"north" = list(0, -8),
		"east" = list(0, -8),
		"south" = list(0, -8),
		"west" = list(0, -8),
	)

/datum/robot_skin/cargo
	abstract_type = /datum/robot_skin/cargo
	icon = CYBORG_ICON_CARGO

/datum/robot_skin/cargo/default
	name = "Technician"
	icon_state = "cargoborg"
	icon_state_light = "cargoborg"
	icon_state_transform = "cargoborg_transform"
	transformation_duration = 4.2 SECONDS
	hat_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)
	badge_offset = list(
		"north" = list(0, 0),
		"east" = list(0, 0),
		"south" = list(0, 0),
		"west" = list(0, 0),
	)

/datum/robot_skin/cargo/zoomba
	name = "Zoomba"
	icon_state = "zoomba_cargo"
	icon_state_light = "zoomba_cargo"
	icon_state_transform = "zoomba_cargo_transform"
	transformation_duration = 4.4 SECONDS
	hat_offset = list(
		"north" = list(0, -9),
		"east" = list(0, -9),
		"south" = list(0, -9),
		"west" = list(0, -9),
	)
	badge_offset = list(
		"north" = list(0, -9),
		"east" = list(0, -9),
		"south" = list(0, -9),
		"west" = list(0, -9),
	)

/datum/robot_skin/cargo/kerfus
	name = "Cargo Kerfus"
	icon_state = "kerfus_cargo"
	icon_state_light = "kerfus_cargo"
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

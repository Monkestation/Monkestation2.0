/datum/robot_skin/cargo
	abstract_type = /datum/robot_skin/cargo
	icon = CYBORG_ICON_CARGO

/datum/robot_skin/cargo/default
	name = "Technician"
	icon_state = "cargoborg"
	icon_state_light = "cargoborg"
	icon_state_transform = "cargoborg_transform"
	hat_offset = 0
	badge_offset = 0

/datum/robot_skin/cargo/zoomba
	name = "Zoomba"
	icon_state = "zoomba_cargo"
	icon_state_light = "zoomba_cargo"
	icon_state_transform = "zoomba_cargo_transform"
	hat_offset = 3
	badge_offset = -9

/datum/robot_skin/cargo/kerfus
	name = "Cargo Kerfus"
	icon_state = "kerfus_cargo"
	icon_state_light = "kerfus_cargo"
	hat_offset = 3
	badge_offset = -6
	traits = list(TRAIT_CAT)

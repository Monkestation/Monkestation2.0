/datum/robot_skin/service
	abstract_type = /datum/robot_skin/service

/datum/robot_skin/service/default
	name = "Butler"
	icon_state = "service_m"
	icon_state_light = "service_m"
	icon_state_transform = "service_m_transform"
	transformation_duration = 4.3 SECONDS
	hat_offset = 0
	badge_offset = -3

/datum/robot_skin/service/waitress
	name = "Waitress"
	icon_state = "service_f"
	icon_state_light = "service_f"
	icon_state_transform = "service_female_transform"
	transformation_duration = 4.5 SECONDS
	hat_offset = 0
	badge_offset = -3

/datum/robot_skin/service/bro
	name = "Bro"
	icon_state = "brobot"
	icon_state_light = "brobot"
	icon_state_transform = "brobot_transform"
	transformation_duration = 5.5 SECONDS
	hat_offset = 0
	badge_offset = -3

/datum/robot_skin/service/kent
	name = "Kent"
	icon_state = "kent"
	icon_state_light = "medical"
	icon_state_transform = "kent_transform"
	transformation_duration = 3.6 SECONDS
	hat_offset = 0
	badge_offset = -3

/datum/robot_skin/service/tophat
	name = "Tophat"
	icon_state = "tophat"
	icon_state_light = "tophat"
	icon_state_transform = "tophat_transform"
	transformation_duration = 5.2 SECONDS
	badge_offset = -3

/datum/robot_skin/service/kerfus
	name = "Service Kerfus"
	icon = CYBORG_ICON_CARGO
	icon_state = "kerfus_service"
	icon_state_light = "kerfus_service"
	hat_offset = 0
	badge_offset = -6
	traits = list(TRAIT_CAT)

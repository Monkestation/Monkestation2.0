/datum/job/bird_watcher
	title = JOB_BIRD_WATCHER
	description = "Amateur ornithologist, watcher of birds, in space or otherwise. Has some strange ideas about imaginary radiogenic birds."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/bird_watcher
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/spring,
		)

	family_heirlooms = list(/obj/item/toy/plush/lobotomy/bigbird)

	mail_goodies = list(
		/obj/item/camera_film
	)

	rpg_title = "Twitcher"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SPRING)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/bird_watcher/special_config_check()
	return CONFIG_GET(flag/spring_enabled)

/datum/outfit/job/bird_watcher
	name = JOB_BIRD_WATCHER
	jobtype = /datum/job/bird_watcher
	suit = /obj/item/clothing/suit/toggle/jacket/hoodie
	back = /obj/item/storage/backpack/satchel
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/binoculars, /obj/item/camera, /obj/item/storage/photo_album/personal)

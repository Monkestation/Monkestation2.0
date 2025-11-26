/datum/job/news_reporter
	title = JOB_NEWS_REPORTER
	description = "A reporter from the Nanotrasen News Network (NNN), report on the goings on of the stations, distribute newspapers, get arrested for trying to get the latest story."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/news_reporter
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/spring,
		)

	family_heirlooms = list(/obj/item/toy/minimeteor)

	mail_goodies = list(
		/obj/item/toy/minimeteor
	)

	rpg_title = "Town Crier"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SPRING)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/news_reporter/special_config_check()
	return CONFIG_GET(flag/spring_enabled)

/datum/outfit/job/news_reporter
	name = "News Reporter"
	jobtype = /datum/job/news_reporter
	head = /obj/item/clothing/head/fedora/beige/press
	uniform = /obj/item/clothing/under/suit/beige
	shoes = /obj/item/clothing/shoes/laceup
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/clothing/mask/cigarette/pipe, /obj/item/clothing/suit/hazardvest/press, /obj/item/clothing/accessory/press_badge, /obj/item/pen/fountain)

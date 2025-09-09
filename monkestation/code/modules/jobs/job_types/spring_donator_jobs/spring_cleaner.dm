/datum/job/spring_cleaner
	title = JOB_SPRING_CLEANER
	description = "A seasonal janitor sent to the station to assist in cleaning."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/spring_cleaner
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

	rpg_title = "Stable Mucker"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SPRING)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/spring_cleaner/special_config_check()
	return CONFIG_GET(flag/spring_enabled)

/datum/outfit/job/spring_cleaner
	name = "Spring Cleaner"
	jobtype = /datum/job/spring_cleaner
	mask = /obj/item/clothing/mask/bandana/purple
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	shoes = /obj/item/clothing/shoes/sneakers/black
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/reagent_containers/spray/cleaner, /obj/item/bodypart/arm/right/robot, /obj/item/bot_assembly/cleanbot, /obj/item/reagent_containers/cup/rag)

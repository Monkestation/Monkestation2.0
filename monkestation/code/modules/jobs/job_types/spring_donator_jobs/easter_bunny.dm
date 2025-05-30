/datum/job/easter_bunny
	title = JOB_EASTER_BUNNY
	description = "Your an assistant with an easter bunny suit. God help you."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/easter_bunny
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/spring,
		)

	family_heirlooms = list(/obj/item/food/egg) // My child

	mail_goodies = list(
		/obj/item/food/grown/carrot,
		/obj/item/food/egg/rotten, // Dont send eggs in the mail
	)

	rpg_title = "Furry Beast"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SPRING)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/easter_bunny/special_config_check()
	return CONFIG_GET(flag/spring_enabled)

/datum/outfit/job/easter_bunny
	name = JOB_EASTER_BUNNY
	jobtype = /datum/job/easter_bunny
	head = /obj/item/clothing/head/costume/bunnyhead/regular
	suit = /obj/item/clothing/suit/costume/bunnysuit/regular
	back = /obj/item/storage/backpack/satchel/bunnysatchel
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/storage/basket/easter)

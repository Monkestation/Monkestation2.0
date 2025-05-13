/datum/job/gorilla
	title = JOB_SPOOKTOBER_GORILLA
	description = "Film a monster movie. Battle godzilla. Get arrested for roaring at lizards."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/gorilla
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/clothing/suit/hooded/gorilla)

	mail_goodies = list(
		/obj/item/food/grown/banana
	)

	rpg_title = "Dire Ape"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER
	job_holiday_flags = list(HALLOWEEN)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/gorilla/special_config_check()
	return CONFIG_GET(flag/spooktober_enabled)

/datum/outfit/job/gorilla
	name = "Gorilla"
	jobtype = /datum/job/gorilla

	suit = /obj/item/clothing/suit/hooded/gorilla
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	r_pocket = /obj/item/megaphone

	backpack_contents = list(
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana
	)

/datum/job/skeleton
	title = JOB_SPOOKTOBER_SKELETON
	description = "Rattle your bones! Rattle the crew! Encourage the skeletons deep within us all to awaken and join the skeleton war."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/skeleton
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/instrument/trombone)

	mail_goodies = list(
		/obj/item/food/cookie/sugar/spookyskull
	)

	rpg_title = "Animated Bones"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER
	job_holiday_flags = list(HALLOWEEN)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/skeleton/special_config_check()
	return CONFIG_GET(flag/spooktober_enabled)

/datum/outfit/job/skeleton
	name = "Skeleton"
	jobtype = /datum/job/skeleton

	uniform = /obj/item/clothing/under/costume/skeleton
	head = /obj/item/clothing/head/helmet/skull
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/instrument/trombone, /obj/item/food/cookie/sugar/spookyskull, /obj/item/food/cookie/sugar/spookyskull, /obj/item/food/cookie/sugar/spookyskull)

/datum/job/hotdog_dude
	title = JOB_HOTDOG
	description = "They say the devil's water it ain't so sweet."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/hotdog_dude
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/summer,
		)

	family_heirlooms = list(/obj/item/food/hotdog)

	mail_goodies = list(
		/obj/item/food/hotdog
	)

	rpg_title = "Sandwich Lord"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SUMMER)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/hotdog_dude/special_config_check()
	return CONFIG_GET(flag/summer_enabled)

/datum/outfit/job/hotdog_dude
	name = JOB_HOTDOG
	jobtype = /datum/job/hotdog_dude
	suit = /obj/item/clothing/suit/hooded/hotdog
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/generic_beacon/hotdog, /obj/item/food/hotdog,/obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog, /obj/item/food/hotdog)



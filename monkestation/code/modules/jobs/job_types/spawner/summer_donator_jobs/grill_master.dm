/datum/job/grill_master
	title = JOB_GRILLER
	description = "Time to grill."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/grill_master
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/summer,
		)

	rpg_title = "Dad"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SUMMER)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/grill_master/special_config_check()
	return CONFIG_GET(flag/summer_enabled)

/datum/outfit/job/grill_master
	name = JOB_GRILLER
	jobtype = /datum/job/grill_master
	suit = /obj/item/clothing/suit/apron/chef
	back = /obj/item/storage/backpack/satchel
	uniform = /obj/item/clothing/under/rank/civilian/chef
	head = /obj/item/clothing/head/soft/fishing_hat
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	shoes = /obj/item/clothing/shoes/colorable_sandals
	backpack_contents = list(/obj/item/kitchen/tongs, /obj/item/stack/sheet/mineral/coal/five, /obj/item/reagent_containers/cup/soda_cans/monkey_energy, /obj/item/generic_beacon/grill)

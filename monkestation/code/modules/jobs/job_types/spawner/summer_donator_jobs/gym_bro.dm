/datum/job/gym_bro
	title = JOB_GYM_BRO
	description = "Everybody wanna to be a bodybuilder... nobody wanna lift these heavy ass weights!"
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/gym_bro
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	allow_overflow = FALSE

	departments_list = list(
		 /datum/job_department/summer,
		)

	family_heirlooms = list(/obj/item/toy/plush/lobotomy/bigbird)

	mail_goodies = list(
		/obj/item/camera_film
	)

	rpg_title = "Strongman"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	job_holiday_flags = list(SUMMER)
	job_donor_bypass = ACCESS_COMMAND_RANK

///This override checks specific config values as a final blocking check.
//Used initially to check if spooktober events were enabled. Edit for your application.
/datum/job/gym_bro/special_config_check()
	return CONFIG_GET(flag/summer_enabled)

/datum/outfit/job/gym_bro
	name = JOB_GYM_BRO
	jobtype = /datum/job/gym_bro
	uniform = /obj/item/clothing/under/shorts/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	glasses = /obj/item/clothing/glasses/fake_sunglasses
	back = /obj/item/storage/backpack/satchel
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	backpack_contents = list(/obj/item/reagent_containers/cup/glass/waterbottle/protein = 3, /obj/item/reagent_containers/spray/spraytan = 1)

/datum/job/machinist
	title = JOB_STATION_MACHINIST
	description = "Hone your skills, make prototypes, \
		and make custom orders."
	department_head = list(JOB_CHIEF_ENGINEER)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_CE
	exp_requirements = 30
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "MACHINIST"

	outfit = /datum/outfit/job/machinist
	plasmaman_outfit = /datum/outfit/plasmaman/engineering

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_ENG

	liver_traits = list(TRAIT_ENGINEER_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MACHINIST
	bounty_types = CIV_JOB_ENG
	departments_list = list(
		/datum/job_department/engineering,
		)

	family_heirlooms = list(/obj/item/clothing/head/utility/hardhat, /obj/item/machining_intermediates/universalcircuit, /obj/item/machining_intermediates/jewelry_t2)

	mail_goodies = list(
		/obj/item/machining_intermediates/fancyring,
		/obj/item/machining_intermediates/sewingsupplies,
		/obj/item/machining_intermediates/moltenplastic,
	)
	rpg_title = "Artificer"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/machinist
	name = "Machinist"
	jobtype = /datum/job/machinist

	id_trim = /datum/id_trim/job/machinist
	uniform = /obj/item/clothing/under/rank/cargo/miner/machinist
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_eng
	head = /obj/item/clothing/head/utility/welding
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/modular_computer/pda/engineering
	r_pocket = /obj/item/machining_intermediates/universalcircuit
	gloves = /obj/item/clothing/gloves/color/black

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

	backpack_contents = list(
		/obj/item/machining_intermediates/moltenplastic,
		/obj/item/stack/machining_intermediates/steel,
	)

	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(/obj/item/skillchip/job/machinist)

/obj/item/clothing/under/rank/cargo/miner/machinist
	desc = "It's a rugged jumpsuit with a sturdy set of overalls. It is very dirty and smells of oil."
	name = "machinist's jumpsuit"

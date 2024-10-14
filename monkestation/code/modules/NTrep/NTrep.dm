/datum/job/nanotrasen_representative
	title = JOB_NANOTRASEN_REPRESENTATIVE
	description = "Protect the heads of staff with your life. You are not a sec officer, and cannot perform arrests."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 900
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "NANOTRASEN_REPRESENTATIVE"

	outfit = /datum/outfit/job/nanotrasen_representative
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_official

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CIV

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_REPRESENTATIVE
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/command,
		)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/pen/fountain = 30,
		/obj/item/food/moonfish_caviar = 25,
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
	)
	rpg_title = "Diplomat"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	alt_titles = list(
		"Corporate Liaison",
		"Nanotrasen Fax Operater",
		"Nanotrasen Official",
		"Nanotrasen Informant",
	)

/datum/outfit/job/nanotrasen_representative
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasen_representative

	id_trim = /datum/id_trim/job/nanotrasen_representative
	uniform = /obj/item/clothing/under/rank/centcom/official
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/folder/blue = 1,
	)
	belt = /obj/item/gun/energy/laser/plasmacore
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/pen/fountain
	r_pocket = /obj/item/modular_computer/pda/heads
	glasses = /obj/item/clothing/glasses/hud/security
	ears = /obj/item/radio/headset/headset_cent
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup

	box = /obj/item/storage/box/survival

	implants = list(/obj/item/implant/mindshield)

/datum/id_trim/job/nanotrasen_representative
	assignment = "Nanotrasen Representative"
	trim_state = "trim_centcom"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_CENTCOM_BLUE
	sechud_icon_state = SECHUD_CENTCOM
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COMMAND,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_WEAPONS,
		ACCESS_CENT_GENERAL,
		ACCESS_CENT_LIVING,
		)
	extra_access = list(
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS
		)
	job = /datum/job/nanotrasen_representative


/datum/job/corporate_liaison
	title = JOB_CORPORATE_LIAISON
	description = "Ensure company interests and report whether Standard Operating Procedure is upheld onboard the station, and get out as soon as you can when it inevitably falls apart. You do not have the authority to give orders, except to the blueshield."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	req_admin_notify = 1
	minimal_player_age = 30
	exp_requirements = 3000
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_CENTRAL_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CORPORATE_LIAISON"

	allow_bureaucratic_error = FALSE
	allow_overflow = FALSE

	outfit = /datum/outfit/job/corporate_liaison
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CMD

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/command,
		)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/lighter, /obj/item/reagent_containers/cup/glass/flask)

	mail_goodies = list(
		/obj/item/pen/fountain = 30,
		/obj/item/food/moonfish_caviar = 25,
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
	)
	exclusive_mail_goodies = TRUE
	rpg_title = "Diplomat"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS

	voice_of_god_power = 1.4 //Command staff has authority

	alt_titles = list(
		"Corporate Liaison",
		"Nanotrasen Fax Operater",
		"Nanotrasen Official",
		"Nanotrasen Informant",
	)
	job_tone = "glory to Nanotrasen!"

/datum/outfit/job/corporate_liaison
	name = "Corporate Liaison"
	jobtype = /datum/job/corporate_liaison
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/job/corporate_liaison
	uniform = /obj/item/clothing/under/rank/centcom/liaison
	suit = /obj/item/clothing/suit/armor/vest/alt
	head = /obj/item/clothing/head/soft/nt
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/folder/blue = 1,
	)
	belt = /obj/item/gun/energy/laser/plasmacore
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/modular_computer/pda/heads/ntrep
	l_hand = /obj/item/storage/secure/briefcase/cash
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/headset_cent/liaison
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup

	chameleon_extras = list(
		/obj/item/gun/energy/laser/plasmacore,
		/obj/item/stamp/centcom,
		)

	implants = list(/obj/item/implant/mindshield)
	pda_slot = ITEM_SLOT_RPOCKET
	skillchips = list(
		/obj/item/skillchip/disk_verifier,
	)



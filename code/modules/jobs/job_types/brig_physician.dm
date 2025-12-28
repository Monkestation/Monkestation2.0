/datum/job/brig_physician
	title = JOB_BRIG_PHYSICIAN
	description = "Stitch up security, prisoners, sometimes the crew."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOS
	exp_requirements = 600
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SECURITY
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIG_PHYSICIAN"

	outfit = /datum/outfit/job/brig_physician
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_MEDICAL_METABOLISM, TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN
	bounty_types = CIV_JOB_MED
	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery)

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 10,
		/obj/item/clothing/glasses/hud/health/sunglasses = 6,
	)
	rpg_title = "Chirurgeon"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/brig_physician
	name = "Brig Physician"
	jobtype = /datum/job/brig_physician

	id_trim = /datum/id_trim/job/brig_physician
	uniform = /obj/item/clothing/under/rank/security/medical/grey
	suit = /obj/item/clothing/suit/toggle/labcoat/secmed/alt
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/modular_computer/pda/security/brig_physician
	ears = /obj/item/radio/headset/headset_secmed
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/medical/secmed/full
	glasses = /obj/item/clothing/glasses/hud/health
	head = /obj/item/clothing/head/soft/sec/medical
	gloves = /obj/item/clothing/gloves/latex/nitrile
	l_pocket = /obj/item/assembly/flash/handheld
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties
	l_hand = /obj/item/storage/medkit/surgery

	backpack = /obj/item/storage/backpack/secmed
	satchel = /obj/item/storage/backpack/satchel/secmed
	duffelbag = /obj/item/storage/backpack/duffelbag/secmed

	backpack_contents = list(
		/obj/item/modular_computer/pda/security/brig_physician = 1,
		/obj/item/emergency_bed = 1,
		)

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	skillchips = list(/obj/item/skillchip/entrails_reader)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/plasmaman/brig_physician
	name = "Brig Physician Plasmaman"

	uniform = /obj/item/clothing/under/plasmaman/secmed
	gloves = /obj/item/clothing/gloves/color/plasmaman/secmed
	head = /obj/item/clothing/head/helmet/space/plasmaman/secmed


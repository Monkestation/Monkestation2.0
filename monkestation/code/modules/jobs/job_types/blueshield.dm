/datum/job/blueshield
	title = JOB_BLUESHIELD
	description = "Protect the heads of staff with your life. You are not a sec officer, and cannot perform arrests."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Representative and Central Command"
	minimal_player_age = 30
	exp_requirements = 7200
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BLUESHIELD"

	allow_bureaucratic_error = FALSE
	allow_overflow = FALSE

	outfit = /datum/outfit/job/blueshield
	plasmaman_outfit = /datum/outfit/plasmaman/blueshield

	paycheck = PAYCHECK_NANOTRASEN
	paycheck_department = ACCOUNT_CC

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BLUESHIELD
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/central_command,
		/datum/job_department/command,
		)
	department_for_prefs = /datum/job_department/central_command

	family_heirlooms = list(/obj/item/bedsheet/captain, /obj/item/clothing/head/beret/blueshield)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 10,
		/obj/item/stack/spacecash/c500 = 3,
		/obj/item/disk/nuclear/fake/obvious = 2,
		/obj/item/clothing/head/collectable/captain = 4,
	)

	rpg_title = "Guard"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS

/datum/job/blueshield/employment_contract_contents(employee_name)
	return "<center>Conditions of Employment</center>\
	<BR><BR><BR><BR>\
	This Agreement is made and entered into as of the date of last signature below, by and between [employee_name] (hereafter referred to as GUARDIAN), \
	and Central Command (hereafter referred to as private military organizaztion).\
	<BR>WITNESSETH:<BR>WHEREAS, GUARDIAN is a natural born human or humanoid, possessing skills upon which private military organizaztion needs, \
	who seeks employment in private military organizaztion.<BR>WHEREAS, private military organizaztion agrees to sporadically provide payment to GUARDIAN, \
	in exchange for their experience in personal protection.<BR>NOW THEREFORE in consideration of the mutual covenants herein contained, and other good and valuable consideration, the parties hereto mutually agree as follows:\
	<BR>In exchange for payments, GUARDIAN agrees to work for private military organizaztion, \
	<BR> and, guard the Heads of Staff of any Nanotrasen area they are stationed in,\
	for the remainder of his or her current and future lives.<BR>Further, GUARDIAN agrees to transfer ownership of his or her soul to the loyalty department of private military organizaztion.\
	<BR>Should transfership of a soul not be possible, a lien shall be placed instead.\
	<BR>Signed,<BR><i>[employee_name]</i>"

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield/jacket
	gloves = /obj/item/clothing/gloves/tackler/combat
	id = /obj/item/card/id/advanced/centcom
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/headset_bs/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses

	implants = list(/obj/item/implant/mindshield)
	backpack_contents = list(
		/obj/item/choice_beacon/blueshield = 1,
	)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel/blueshield
	duffelbag = /obj/item/storage/backpack/duffelbag/blueshield

	head = /obj/item/clothing/head/beret/blueshield
	box = /obj/item/storage/box/survival/security
	belt = /obj/item/storage/belt/military/assault/blueshield
	l_pocket = /obj/item/sensor_device/command
	r_pocket = /obj/item/modular_computer/pda/blueshield
	pda_slot = ITEM_SLOT_RPOCKET
	id_trim = /datum/id_trim/job/blueshield

/datum/outfit/plasmaman/blueshield
	name = "Blueshield Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman/blueshield
	uniform = /obj/item/clothing/under/plasmaman/blueshield

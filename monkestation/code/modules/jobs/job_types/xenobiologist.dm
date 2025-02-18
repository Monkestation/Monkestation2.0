/datum/job/xenobiologist
	title = JOB_XENOBIOLOGIST
	description = "Feed the slimes, grow a variety of creatures in vats, study all that is alien. And don't let the Queen loose."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_RD
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "XENOBIOLOGIST"

	outfit = /datum/outfit/job/xenobiologist
	plasmaman_outfit = /datum/outfit/plasmaman/science

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_BALLMER_SCIENTIST)

	display_order = JOB_DISPLAY_ORDER_XENOBIOLOGIST
	bounty_types = CIV_JOB_XENO
	departments_list = list(
		/datum/job_department/science,
		)

	family_heirlooms = list(
		/obj/item/book/manual/wiki/cytology,
		/obj/item/toy/plush/slimeplushie
	)

	mail_goodies = list(
		/obj/item/toy/plush/slimeplushie = 10,
		/obj/item/disk/design_disk/bepis = 2,
	)
	rpg_title = "Beastiary"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/xenobiologist
	name = "Xenobiologist"
	jobtype = /datum/job/xenobiologist

	id_trim = /datum/id_trim/job/xenobiologist
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/hooded/wintercoat/science
	belt = /obj/item/modular_computer/pda/science
	ears = /obj/item/radio/headset/headset_sci
	shoes = /obj/item/clothing/shoes/winterboots
	glasses = /obj/item/clothing/glasses/science
	gloves = /obj/item/clothing/gloves/color/grey/protects_cold

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science


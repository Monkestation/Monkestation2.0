/datum/job/explorer
	title = JOB_LATEJOIN_EXPLORER
	description = "Travel to strange lands. Mine ores. \
		Meet strange creatures. Kill them for their gold."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_QM
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "EXPLORER"

	outfit = /datum/outfit/job/explorer
	plasmaman_outfit = /datum/outfit/plasmaman/mining

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR

	mind_traits = list(TRAIT_DETECT_STORM)

	display_order = JOB_LATEJOIN_EXPLORER
	bounty_types = CIV_JOB_MINE
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(
		/obj/item/pickaxe/mini,
		/obj/item/shovel,
		/obj/item/gps/mining,
		/obj/item/toy/plush/carpplushie,
		)
	rpg_title = "Adventurer"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/explorer
	name = "Explorer"
	jobtype = /datum/job/explorer

	id_trim = /datum/id_trim/job/explorer
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/tank/jetpack/mining = 1,
		/obj/item/clothing/suit/space/hardsuit/mining = 1,
		/obj/item/pickaxe/mini = 1,
		/obj/item/gps/mining = 1,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 1,
	)
	belt = /obj/item/modular_computer/pda/shaftminer
	ears = /obj/item/radio/headset/headset_cargo/mining
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots/mining
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore //causes issues if spawned in backpack

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag/explorer

	box = /obj/item/storage/box/survival/mining
	chameleon_extras = /obj/item/gun/energy/recharge/kinetic_accelerator

